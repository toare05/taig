import Foundation

/// 태그 도메인 모델
struct Tag: Identifiable, Hashable {
    let id: UUID
    let name: String
    let createdAt: Date
    
    /// TagEntity에서 Tag 도메인 모델 생성
    /// - Parameter entity: CoreData TagEntity
    init(entity: TagEntity) {
        self.id = entity.id ?? UUID()
        self.name = entity.name ?? ""
        self.createdAt = entity.createdAt ?? Date()
    }
    
    /// 새 Tag 인스턴스 생성
    init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
    
    // Hashable 프로토콜 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable 프로토콜 구현
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }
} 