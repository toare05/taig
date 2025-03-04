import SwiftUI

/// 태그 입력을 위한 팝업 뷰
struct TagInputPopupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var tagText = ""
    @State private var tags: [Tag] = []
    
    var image: UIImage
    var onSave: ([String]) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // 이미지 미리보기
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding(.top)
                
                // 태그 입력 필드
                TagInputField(text: $tagText, tags: $tags)
                    .padding(.horizontal)
                
                // 현재 입력된 태그 목록
                if !tags.isEmpty {
                    ScrollView {
                        TagListView(tags: tags) { tag in
                            if let index = tags.firstIndex(where: { $0.id == tag.id }) {
                                tags.remove(at: index)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 100)
                } else {
                    Text("태그를 입력해주세요")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
                
                // 저장 버튼
                Button(action: saveAction) {
                    Text("저장")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .disabled(tags.isEmpty)
            }
            .navigationTitle("태그 추가")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func saveAction() {
        let tagNames = tags.map { $0.name }
        onSave(tagNames)
        presentationMode.wrappedValue.dismiss()
    }
} 