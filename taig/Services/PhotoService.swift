import Foundation
import Photos
import UIKit
import SwiftUI

/// 사진 관련 기능을 제공하는 서비스 클래스
class PhotoService: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = PhotoService()
    
    // 사진 접근 권한 상태
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    private init() {
        // 현재 권한 상태 확인
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    /// 사진 라이브러리 접근 권한 요청
    /// - Parameter completion: 권한 요청 완료 후 호출될 클로저
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
                completion(status == .authorized)
            }
        }
    }
    
    /// 사진 라이브러리에서 최근 사진 가져오기
    /// - Parameter completion: 사진 가져오기 완료 후 호출될 클로저
    func fetchRecentPhotos(completion: @escaping ([PHAsset]) -> Void) {
        // 권한 확인
        guard authorizationStatus == .authorized else {
            completion([])
            return
        }
        
        // 최근 사진 가져오기 옵션 설정
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 30 // 최대 30개까지만 가져오기
        
        // 사진 가져오기
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        completion(assets)
    }
    
    /// PHAsset에서 UIImage로 변환
    /// - Parameters:
    ///   - asset: 변환할 PHAsset
    ///   - targetSize: 원하는 이미지 크기
    ///   - completion: 변환 완료 후 호출될 클로저
    func getImage(from asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            completion(image)
        }
    }
    
    /// 카메라로 찍은 사진을 앱 내부 저장소에 저장
    /// - Parameters:
    ///   - image: 저장할 UIImage
    ///   - completion: 저장 완료 후 호출될 클로저 (저장된 파일 URL 반환)
    func saveImageToDocuments(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        // 파일명 생성 (UUID 사용)
        let filename = UUID().uuidString + ".jpg"
        
        // 문서 디렉토리 URL 가져오기
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil)
            return
        }
        
        // 저장할 파일 URL 생성
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        // 파일 저장
        do {
            try data.write(to: fileURL)
            completion(fileURL)
        } catch {
            print("이미지 저장 실패: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    /// 썸네일 이미지 생성
    /// - Parameters:
    ///   - image: 원본 UIImage
    ///   - size: 썸네일 크기
    /// - Returns: 썸네일 이미지 데이터
    func createThumbnail(from image: UIImage, size: CGSize) -> Data? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnailImage?.jpegData(compressionQuality: 0.5)
    }
} 