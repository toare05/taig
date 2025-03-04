import Foundation

/// 사진 도메인 모델
struct Photo: Identifiable {
    let id: UUID
    let imageURL: String
    let imageData: Data?
    let createdAt: Date
    let modifiedAt: Date
    var tags: [Tag]
    
    /// PhotoEntity에서 Photo 도메인 모델 생성
    /// - Parameter entity: CoreData PhotoEntity
    init(entity: PhotoEntity) {
        self.id = entity.id ?? UUID()
        self.imageURL = entity.imageURL ?? ""
        self.imageData = entity.imageData
        self.createdAt = entity.createdAt ?? Date()
        self.modifiedAt = entity.modifiedAt ?? Date()
        
        // 태그 관계 변환
        if let tagSet = entity.tags as? Set<TagEntity> {
            self.tags = tagSet.map { Tag(entity: $0) }
        } else {
            self.tags = []
        }
    }
    
    /// 새 Photo 인스턴스 생성
    init(id: UUID = UUID(), imageURL: String, imageData: Data? = nil, tags: [Tag] = [], createdAt: Date = Date(), modifiedAt: Date = Date()) {
        self.id = id
        self.imageURL = imageURL
        self.imageData = imageData
        self.tags = tags
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
} 