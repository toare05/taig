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
    @StateObject private var cameraViewModel = CameraViewModel(context: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        NavigationView {
            VStack {
                // 최근 사진 그리드 (나중에 구현)
                if cameraViewModel.isLoading {
                    ProgressView("사진 로딩 중...")
                } else if cameraViewModel.recentPhotoImages.isEmpty {
                    Text("최근 사진이 없습니다")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Text("최근 사진")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // 나중에 여기에 사진 그리드 구현
                }
                
                Spacer()
                
                // 카메라 및 갤러리 버튼
                HStack(spacing: 30) {
                    // 카메라 버튼
                    Button(action: {
                        cameraViewModel.isShowingCamera = true
                    }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 30))
                            Text("카메라")
                                .font(.caption)
                        }
                    }
                    
                    // 갤러리 버튼
                    Button(action: {
                        cameraViewModel.isShowingPhotoLibrary = true
                    }) {
                        VStack {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 30))
                            Text("갤러리")
                                .font(.caption)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Taig")
            .sheet(isPresented: $cameraViewModel.isShowingCamera) {
                CameraView { image in
                    cameraViewModel.processCapturedImage(image)
                }
            }
            .sheet(isPresented: $cameraViewModel.isShowingPhotoLibrary) {
                PhotoLibraryView { image in
                    cameraViewModel.processSelectedImage(image)
                }
            }
            .sheet(isPresented: $cameraViewModel.isShowingTagInput, onDismiss: {
                // 태그 입력 팝업이 닫힐 때 처리
                print("태그 입력 팝업 닫힘")
            }) {
                if let image = cameraViewModel.selectedImage {
                    TagInputPopupView(image: image) { tags in
                        cameraViewModel.savePhotoWithTags(image: image, tags: tags)
                    }
                }
            }
            .onAppear {
                cameraViewModel.checkPhotoLibraryPermission()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
