import CoreData

/// CoreData 스택을 관리하는 클래스
struct PersistenceController {
    // 싱글톤 인스턴스
    static let shared = PersistenceController()
    
    // 미리보기용 인스턴스
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // 미리보기용 샘플 데이터 생성
        let viewContext = controller.container.viewContext
        
        // 샘플 태그 생성
        let sampleTag = TagEntity(context: viewContext)
        sampleTag.id = UUID()
        sampleTag.name = "샘플 태그"
        sampleTag.createdAt = Date()
        
        // 샘플 사진 생성
        let samplePhoto = PhotoEntity(context: viewContext)
        samplePhoto.id = UUID()
        samplePhoto.imageURL = "sample_url"
        samplePhoto.createdAt = Date()
        samplePhoto.modifiedAt = Date()
        
        // 관계 설정
        samplePhoto.addToTags(sampleTag)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("미리보기 컨텍스트 저장 실패: \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    // NSPersistentContainer 인스턴스
    let container: NSPersistentContainer
    
    /// 기본 생성자
    /// - Parameter inMemory: 메모리 내 저장소 사용 여부 (테스트용)
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaigDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // 실제 앱에서는 더 적절한 오류 처리가 필요합니다
                fatalError("CoreData 스토어 로드 실패: \(error), \(error.userInfo)")
            }
        }
        
        // 병합 정책 설정
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /// 변경사항 저장
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("CoreData 컨텍스트 저장 실패: \(nsError), \(nsError.userInfo)")
            }
        }
    }
} 