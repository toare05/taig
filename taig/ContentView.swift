//
//  ContentView.swift
//  taig
//
//  Created by MINJE JO on 3/4/25.
//

import SwiftUI
import Photos

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var screenshotViewModel = ScreenshotViewModel(context: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        NavigationView {
            VStack {
                // 스크린샷 감지 안내 텍스트
                Text("스크린샷을 찍으면 자동으로 태그를 추가할 수 있습니다")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                Text("앱을 사용하는 동안 스크린샷을 찍으면\n자동으로 태그 입력 화면이 표시됩니다")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // 최근 스크린샷 그리드
                if screenshotViewModel.isLoading {
                    ProgressView("스크린샷 로딩 중...")
                        .padding(.top, 40)
                } else if screenshotViewModel.recentPhotoImages.isEmpty {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                        
                        Text("최근 스크린샷이 없습니다")
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    Text("최근 스크린샷")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // 나중에 여기에 스크린샷 그리드 구현
                }
                
                Spacer()
            }
            .navigationTitle("Taig")
            .sheet(isPresented: $screenshotViewModel.isShowingTagInput, onDismiss: {
                // 태그 입력 팝업이 닫힐 때 처리
                print("태그 입력 팝업 닫힘")
            }) {
                if let image = screenshotViewModel.selectedImage {
                    TagInputPopupView(image: image) { tags in
                        screenshotViewModel.savePhotoWithTags(image: image, tags: tags)
                    }
                }
            }
            .onAppear {
                screenshotViewModel.checkPhotoLibraryPermission()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
