# Taig 프로젝트 아키텍처 문서

## 1. 개요
Taig는 사용자가 사진을 캡처하고 즉시 태그를 추가할 수 있는 iOS 앱입니다. 이 문서는 앱의 전체적인 구조와 기술 스택을 설명합니다.

## 2. 기술 스택
- **언어**: Swift 5.5+
- **UI 프레임워크**: SwiftUI
- **최소 iOS 버전**: iOS 15+
- **데이터 저장**: CoreData
- **사진 관리**: PhotoKit
- **알림**: UserNotifications 프레임워크

## 3. 아키텍처 패턴
Taig는 **MVVM(Model-View-ViewModel)** 패턴을 사용합니다. 이 패턴은 SwiftUI와 자연스럽게 통합되며 다음과 같은 이점이 있습니다:

- **관심사 분리**: UI(View)와 비즈니스 로직(ViewModel)을 명확히 분리
- **테스트 용이성**: ViewModel은 UI에 의존하지 않아 단위 테스트가 쉬움
- **코드 재사용**: 동일한 ViewModel을 여러 View에서 사용 가능
- **상태 관리**: SwiftUI의 상태 관리 기능과 자연스럽게 통합

### 3.1 구성 요소
- **Model**: 앱의 데이터 구조와 비즈니스 로직
- **View**: 사용자 인터페이스 (SwiftUI)
- **ViewModel**: View와 Model 사이의 중개자, UI 상태 관리

## 4. 폴더 구조
```
Taig/
├── App/
│   └── TaigApp.swift (앱 진입점)
├── Models/
│   ├── CoreData/ (CoreData 모델 및 관리)
│   └── Domain/ (도메인 모델)
├── Views/
│   ├── Camera/ (카메라 및 사진 캡처 관련 뷰)
│   ├── Tags/ (태그 관리 관련 뷰)
│   ├── Search/ (검색 관련 뷰)
│   ├── Settings/ (설정 관련 뷰)
│   └── Common/ (공통 UI 컴포넌트)
├── ViewModels/
│   ├── CameraViewModel.swift
│   ├── TagsViewModel.swift
│   ├── SearchViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── PhotoService.swift (PhotoKit 연동)
│   ├── StorageService.swift (CoreData 관리)
│   └── NotificationService.swift (알림 관리)
└── Utils/
    ├── Extensions/ (Swift 확장)
    └── Helpers/ (유틸리티 함수)
```

## 5. 데이터 모델
### 5.1 CoreData 엔티티
- **Photo**
  - `id`: UUID
  - `imageData`: Binary Data (선택적, 작은 썸네일용)
  - `imageURL`: String (사진 파일 경로)
  - `createdAt`: Date
  - `modifiedAt`: Date
  - `tags`: 관계 (Tag 엔티티와 다대다 관계)

- **Tag**
  - `id`: UUID
  - `name`: String
  - `createdAt`: Date
  - `photos`: 관계 (Photo 엔티티와 다대다 관계)

### 5.2 도메인 모델
CoreData 엔티티를 래핑하는 Swift 구조체를 사용하여 앱 내에서 데이터를 처리합니다.

## 6. 주요 기능 흐름
### 6.1 사진 캡처 및 태그 추가
1. 사용자가 카메라 뷰에서 사진 촬영
2. 사진 미리보기 표시
3. 태그 입력 팝업 표시
4. 사용자가 태그 입력
5. 사진과 태그 저장

### 6.2 태그 기반 검색
1. 사용자가 검색 뷰에서 태그 선택 또는 입력
2. 해당 태그가 있는 사진 필터링
3. 결과 표시

## 7. 성능 고려사항
- 대용량 사진 처리를 위한 메모리 관리
- 태그 검색 최적화
- 백그라운드 작업 처리

## 8. 보안 고려사항
- 모든 데이터는 기기 내에서만 처리 (온디바이스)
- 사진 접근 권한 관리
- 카메라 접근 권한 관리

## 9. 확장성
향후 추가될 기능을 고려한 설계:
- AI 태그 추천
- 알람 설정
- 캘린더 연동
- iCloud 동기화 