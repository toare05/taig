import SwiftUI

/// 태그를 표시하는 UI 컴포넌트
struct TagView: View {
    let tag: Tag
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name)
                .font(.footnote)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.trailing, 4)
            }
        }
        .background(Color.blue)
        .cornerRadius(12)
    }
}

/// 여러 태그를 표시하는 컨테이너 뷰
struct TagListView: View {
    let tags: [Tag]
    var onDeleteTag: ((Tag) -> Void)? = nil
    
    var body: some View {
        FlowLayout(alignment: .leading, spacing: 8) {
            ForEach(tags) { tag in
                TagView(tag: tag) {
                    onDeleteTag?(tag)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

/// 태그 입력 필드
struct TagInputField: View {
    @Binding var text: String
    @Binding var tags: [Tag]
    var onCommit: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            TextField("태그 입력 후 엔터", text: $text, onCommit: {
                addTag()
                onCommit?()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: addTag) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
        }
    }
    
    private func addTag() {
        let tagText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !tagText.isEmpty && !tags.contains(where: { $0.name.lowercased() == tagText.lowercased() }) {
            tags.append(Tag(name: tagText))
            text = ""
        }
    }
}

/// 태그를 여러 줄로 표시하기 위한 레이아웃
struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .center
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        
        var height: CGFloat = 0
        var width: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if rowWidth + size.width > containerWidth {
                // 새 줄 시작
                width = max(width, rowWidth)
                height += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                // 현재 줄에 추가
                rowWidth += size.width + (rowWidth > 0 ? spacing : 0)
                rowHeight = max(rowHeight, size.height)
            }
        }
        
        // 마지막 줄 처리
        width = max(width, rowWidth)
        height += rowHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let containerWidth = bounds.width
        
        var rowX: CGFloat = bounds.minX
        var rowY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if rowX + size.width > containerWidth + bounds.minX {
                // 새 줄 시작
                rowX = bounds.minX
                rowY += rowHeight + spacing
                rowHeight = 0
            }
            
            subview.place(at: CGPoint(x: rowX, y: rowY), proposal: .unspecified)
            
            rowX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    VStack {
        TagListView(tags: [
            Tag(name: "여행"),
            Tag(name: "음식"),
            Tag(name: "가족"),
            Tag(name: "일상"),
            Tag(name: "기념일")
        ])
        
        Divider()
        
        let binding = Binding<String>(
            get: { "" },
            set: { _ in }
        )
        
        let tagsBinding = Binding<[Tag]>(
            get: { [Tag(name: "테스트")] },
            set: { _ in }
        )
        
        TagInputField(text: binding, tags: tagsBinding)
    }
    .padding()
} 