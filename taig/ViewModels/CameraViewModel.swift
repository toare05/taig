import Foundation
import SwiftUI
import Photos
import CoreData

/// 카메라 및 사진 관련 기능을 관리하는 ViewModel
class CameraViewModel: ObservableObject {
    // 서비스 인스턴스
    private let photoService = PhotoService.shared
    
    // 상태 변수
    @Published var isShowingCamera = false
    @Published var isShowingPhotoLibrary = false
    @Published var selectedImage: UIImage?
    @Published var isShowingTagInput = false
    @Published var recentPhotos: [PHAsset] = []
    @Published var recentPhotoImages: [UIImage] = []
    @Published var isLoading = false
    
    // 스크린샷 감지 관련
    private var screenshotObserver: NSObjectProtocol?
    
    // CoreData 관련
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        checkPhotoLibraryPermission()
        setupScreenshotDetection()
    }
    
    deinit {
        if let observer = screenshotObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// 스크린샷 감지 설정
    private func setupScreenshotDetection() {
        screenshotObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("스크린샷이 감지되었습니다!")
            self?.handleScreenshot()
        }
    }
    
    /// 스크린샷 처리
    private func handleScreenshot() {
        // 가장 최근 스크린샷 가져오기
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaSubtype = %d", PHAssetMediaSubtype.photoScreenshot.rawValue)
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if let asset = fetchResult.firstObject {
            photoService.getImage(from: asset, targetSize: PHImageManagerMaximumSize) { [weak self] image in
                guard let self = self, let image = image else { return }
                
                DispatchQueue.main.async {
                    self.selectedImage = image
                    self.isShowingTagInput = true
                    print("스크린샷 처리: 태그 입력 팝업 표시")
                }
            }
        }
    }
    
    /// 사진 라이브러리 권한 확인 및 요청
    func checkPhotoLibraryPermission() {
        if photoService.authorizationStatus == .notDetermined {
            photoService.requestAuthorization { [weak self] granted in
                if granted {
                    self?.loadRecentPhotos()
                }
            }
        } else if photoService.authorizationStatus == .authorized {
            loadRecentPhotos()
        }
    }
    
    /// 최근 사진 로드
    func loadRecentPhotos() {
        isLoading = true
        photoService.fetchRecentPhotos { [weak self] assets in
            guard let self = self else { return }
            
            self.recentPhotos = assets
            self.loadThumbnails(for: assets)
        }
    }
    
    /// 썸네일 이미지 로드
    /// - Parameter assets: 썸네일을 로드할 PHAsset 배열
    private func loadThumbnails(for assets: [PHAsset]) {
        let targetSize = CGSize(width: 200, height: 200)
        
        var images: [UIImage] = []
        let group = DispatchGroup()
        
        for asset in assets {
            group.enter()
            photoService.getImage(from: asset, targetSize: targetSize) { image in
                if let image = image {
                    images.append(image)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.recentPhotoImages = images
            self?.isLoading = false
        }
    }
    
    /// 카메라로 찍은 사진 처리
    /// - Parameter image: 카메라로 찍은 UIImage
    func processCapturedImage(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.selectedImage = image
            self.isShowingTagInput = true
            print("카메라로 찍은 사진 처리: 태그 입력 팝업 표시")
        }
    }
    
    /// 갤러리에서 선택한 사진 처리
    /// - Parameter image: 갤러리에서 선택한 UIImage
    func processSelectedImage(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.selectedImage = image
            self.isShowingTagInput = true
            print("갤러리에서 선택한 사진 처리: 태그 입력 팝업 표시")
        }
    }
    
    /// 사진과 태그 저장
    /// - Parameters:
    ///   - image: 저장할 UIImage
    ///   - tags: 태그 문자열 배열
    func savePhotoWithTags(image: UIImage, tags: [String]) {
        guard let image = selectedImage else { return }
        
        // 저장 시작 로그
        print("사진 저장 시작: \(tags.count)개의 태그")
        
        // 이미지를 앱 내부 저장소에 저장
        photoService.saveImageToDocuments(image: image) { [weak self] fileURL in
            guard let self = self, let fileURL = fileURL else { 
                print("이미지 저장 실패")
                return 
            }
            
            // 썸네일 생성
            let thumbnailData = self.photoService.createThumbnail(
                from: image,
                size: CGSize(width: 300, height: 300)
            )
            
            // CoreData에 저장
            self.saveToDatabase(imageURL: fileURL.path, thumbnailData: thumbnailData, tagNames: tags)
        }
    }
    
    /// CoreData에 사진과 태그 저장
    /// - Parameters:
    ///   - imageURL: 이미지 파일 경로
    ///   - thumbnailData: 썸네일 이미지 데이터
    ///   - tagNames: 태그 이름 배열
    private func saveToDatabase(imageURL: String, thumbnailData: Data?, tagNames: [String]) {
        viewContext.perform { [weak self] in
            guard let self = self else { return }
            
            // 새 Photo 엔티티 생성
            let photoEntity = PhotoEntity(context: self.viewContext)
            photoEntity.id = UUID()
            photoEntity.imageURL = imageURL
            photoEntity.imageData = thumbnailData
            photoEntity.createdAt = Date()
            photoEntity.modifiedAt = Date()
            
            // 태그가 있는 경우에만 태그 생성 및 연결
            if !tagNames.isEmpty {
                for tagName in tagNames {
                    // 이미 존재하는 태그인지 확인
                    let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "name == %@", tagName)
                    
                    do {
                        let results = try self.viewContext.fetch(fetchRequest)
                        let tagEntity: TagEntity
                        
                        if let existingTag = results.first {
                            // 기존 태그 사용
                            tagEntity = existingTag
                        } else {
                            // 새 태그 생성
                            tagEntity = TagEntity(context: self.viewContext)
                            tagEntity.id = UUID()
                            tagEntity.name = tagName
                            tagEntity.createdAt = Date()
                        }
                        
                        // 태그와 사진 연결
                        photoEntity.addToTags(tagEntity)
                    } catch {
                        print("태그 검색 실패: \(error.localizedDescription)")
                    }
                }
            }
            
            // 변경사항 저장
            do {
                try self.viewContext.save()
                print("사진 및 태그 저장 완료")
                
                // UI 업데이트는 메인 스레드에서
                DispatchQueue.main.async {
                    self.selectedImage = nil
                    self.isShowingTagInput = false
                    // 최근 사진 다시 로드
                    self.loadRecentPhotos()
                }
            } catch {
                print("저장 실패: \(error.localizedDescription)")
            }
        }
    }
} 