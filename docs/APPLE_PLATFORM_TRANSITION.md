# Dday Apple Platform Transition Design

작성일: 2026-06-04

## 1. 목표

`Dday`를 현재 macOS 메뉴바 앱에서 iPhone, iPad, 그리고 장기적으로 App Store 배포까지 가능한 Apple 플랫폼 앱으로 확장합니다.

핵심 방향은 새 앱을 처음부터 완전히 다시 만드는 것이 아니라, 이미 구현된 `DdayCore`를 공유하고 각 플랫폼의 UI만 따로 만드는 것입니다. 학회 데이터 모델, AoE 타임존 처리, D-Day 계산, 사용자 지정 D-Day, 데이터 업데이트 로직은 최대한 공통 코드로 유지합니다.

최종 목표는 다음과 같습니다.

- macOS: 메뉴바에서 선택한 학회 데드라인을 계속 표시
- iPhone: 앱, 홈 화면 위젯, 잠금 화면 위젯으로 데드라인 확인
- iPad: 넓은 화면에서 카테고리, 학회 목록, 상세 정보를 동시에 탐색
- App Store: TestFlight 베타를 거쳐 공개 출시
- GitHub: macOS DMG/ZIP 배포와 데이터 기여 흐름 유지

## 2. 현재 상태

현재 프로젝트는 `/Users/mindw/Documents/Projects/Dday`에 있고 Swift Package 기반입니다.

```text
Dday/
  Package.swift
  Sources/
    DdayCore/
    DdayApp/
  Checks/
    DdayCoreChecks/
  data/
  docs/
  scripts/
```

현재 구조에서 가장 좋은 점은 `DdayCore`가 이미 분리되어 있다는 것입니다.

```text
Sources/DdayCore/
  Models/
    Conference.swift
    ConferenceDeadline.swift
    DeadlineSelection.swift
    UserDeadline.swift
  Services/
    ConferenceDataUpdater.swift
    ConferenceStore.swift
    DeadlineCalculator.swift
    SettingsStore.swift
    UserDeadlineStore.swift
```

이 코어는 대부분 `Foundation` 기반이라 iOS/iPadOS에서도 재사용하기 좋습니다. 반대로 `Sources/DdayApp`은 AppKit과 `NSStatusItem`에 의존하므로 macOS 전용으로 유지합니다.

현재 확인된 개발 환경 상태:

- macOS 자체는 iOS/iPadOS 개발이 가능한 상태입니다.
- Apple Silicon 환경입니다.
- 정식 Xcode는 아직 설치 또는 활성화되어 있지 않고 Command Line Tools만 활성화되어 있습니다.

따라서 다음 실제 개발 단계 전에 Xcode 설치와 Apple Developer 계정 연결이 필요합니다.

## 3. 제품 해석

iOS와 iPadOS에는 macOS 메뉴바 같은 상시 표시 영역이 없습니다. 따라서 macOS 앱의 가치를 그대로 옮기려면 "상태창 앱"이 아니라 "앱 + 위젯 + 알림" 조합으로 바꿔야 합니다.

플랫폼별 역할은 다음과 같이 정의합니다.

| 플랫폼 | 핵심 경험 | 우선순위 |
| --- | --- | --- |
| macOS | 메뉴바 배지와 드롭다운 메뉴 | 유지 |
| iPhone | 선택한 D-Day, 즐겨찾기, 위젯, 알림 | 1차 출시 |
| iPad | 카테고리 탐색, 학회 상세, 여러 데드라인 비교 | 1차 출시 |
| Widget | 홈 화면/잠금 화면에서 D-Day 표시 | 1차 출시 |
| TestFlight | 친구와 연구실 구성원 대상 베타 테스트 | 1차 출시 전 |
| App Store | 공개 배포 | 베타 안정화 후 |

## 4. 저장소 구조 전략

처음부터 `macOS`, `iOS`, `iPadOS`를 모두 별도 폴더로 강하게 나누면 관리가 복잡해질 수 있습니다. iPhone과 iPad는 보통 하나의 Universal iOS 앱 타깃으로 만들고, 화면 크기에 따라 레이아웃만 다르게 구성합니다.

권장 구조는 다음과 같습니다.

```text
Dday/
  Package.swift
  Sources/
    DdayCore/                 # 모든 Apple 플랫폼이 공유하는 핵심 로직
    DdayApp/                  # 현재 macOS SwiftPM 메뉴바 앱
  Apps/
    Mobile/
      DdayMobile.xcodeproj    # iPhone/iPad 앱과 Widget 타깃
      DdayMobile/
        DdayMobileApp.swift
        Screens/
        Components/
        Resources/
        Assets.xcassets/
      DdayWidgets/
        DdayWidgetsBundle.swift
        DeadlineWidget.swift
      DdayMobileTests/
      DdayMobileUITests/
  Checks/
    DdayCoreChecks/
  data/
    conferences.json
    schema.json
  docs/
    APPLE_PLATFORM_TRANSITION.md
```

초기에는 현재 macOS 앱을 옮기지 않습니다. `Sources/DdayApp`은 그대로 두고, `Apps/Mobile` 아래에 Xcode 프로젝트를 추가합니다. 이렇게 하면 기존 GitHub Release와 macOS CI가 흔들리지 않습니다.

나중에 Mac App Store까지 진지하게 가게 되면, 그때 macOS 앱도 Xcode 프로젝트로 옮길지 결정합니다.

## 5. 패키지와 타깃 설계

현재 `Package.swift`는 macOS만 선언합니다.

```swift
platforms: [
    .macOS(.v13)
]
```

iOS/iPadOS 앱에서 `DdayCore`를 가져다 쓰려면 다음처럼 iOS 플랫폼도 추가합니다.

```swift
platforms: [
    .macOS(.v13),
    .iOS(.v17)
]
```

권장 타깃:

| 타깃 | 종류 | 역할 |
| --- | --- | --- |
| `DdayCore` | Swift Package library | 모델, 날짜 계산, 데이터 로딩, 설정 로직 |
| `DdayApp` | Swift Package executable | 기존 macOS 메뉴바 앱 |
| `DdayCoreChecks` | Swift Package executable | 데이터와 코어 로직 검증 |
| `DdayMobile` | Xcode iOS app target | iPhone/iPad 앱 |
| `DdayWidgets` | Xcode widget extension | 홈 화면/잠금 화면 위젯 |
| `DdayMobileTests` | Xcode test target | 모바일 UI와 상태 테스트 |

중요한 원칙은 `DdayCore`가 AppKit, UIKit, SwiftUI, WidgetKit을 직접 알지 않게 하는 것입니다. 코어는 데이터를 계산하고, 앱과 위젯은 그 결과를 보여주는 역할만 합니다.

## 6. iPhone 앱 MVP

iPhone 첫 버전은 복잡한 캘린더 앱이 아니라 "내가 선택한 연구 데드라인을 빠르게 보는 앱"으로 시작합니다.

필수 화면:

- Home
  - 현재 선택된 대표 D-Day
  - 로컬 타임존 기준 마감 시각
  - AoE 원본 마감 정보
  - 학회 홈페이지 열기
- Conferences
  - Machine Learning, Computer Vision, NLP, General AI 카테고리
  - 학회 목록
  - 지난 학회 숨김 또는 Past Conferences 섹션
- Conference Detail
  - abstract, full paper, supplementary, notification 등 모든 deadline
  - 메인 D-Day로 설정
  - 출처 URL 표시
- Custom D-Day
  - 목록에 없는 개인 마감일 추가
  - 삭제
- Settings
  - 언어
  - 표시 방식
  - 데이터 업데이트 확인
  - 개인정보 안내

권장 내비게이션:

- iPhone: `TabView` + `NavigationStack`
- 탭: `Home`, `Conferences`, `Custom`, `Settings`

## 7. iPad 앱 MVP

iPad는 같은 앱 타깃 안에서 더 넓은 레이아웃을 제공합니다.

권장 구조:

- 왼쪽 사이드바: 카테고리
- 가운데 목록: 해당 카테고리의 학회
- 오른쪽 상세: 선택한 학회의 데드라인과 출처

SwiftUI에서는 `NavigationSplitView`가 자연스럽습니다. iPhone에서는 자동으로 stack 형태로 접히고, iPad에서는 2열 또는 3열 탐색으로 보입니다.

iPad에서 추가로 유용한 기능:

- 여러 deadline을 한 화면에서 비교
- 즐겨찾기 학회 묶음
- 학회 상세와 사용자 지정 D-Day 편집을 넓은 화면에서 동시에 보기

## 8. Widget 설계

iOS/iPadOS에서 macOS 메뉴바의 대체물은 Widget입니다.

1차 Widget:

- Small
  - `AAAI`
  - `D-62`
- Medium
  - 학회명
  - deadline label
  - 로컬 마감 날짜
  - `D-62`
- Lock Screen
  - `AAAI D-62`
  - 또는 `D-62`

Widget은 앱의 최신 상태를 직접 마음대로 계속 가져오지 못합니다. 따라서 앱과 위젯이 같은 데이터를 읽으려면 App Group을 사용합니다.

권장 App Group:

```text
group.dev.mindw.Dday
```

공유할 데이터:

- 선택된 대표 deadline
- 즐겨찾기 deadline 일부
- 캐시된 conference JSON
- 사용자 지정 D-Day
- 언어와 표시 설정 일부

Widget 업데이트 전략:

- 앱에서 설정이 바뀌면 Widget timeline reload 요청
- 하루 단위 D-Day는 자정 근처에 갱신
- D-Day 당일 H/M 표시가 필요하면 더 짧은 timeline을 구성하되 배터리와 시스템 제한을 고려

## 9. 알림 설계

알림은 1차 App Store 출시 전에 넣을 가치가 큽니다. 연구자 앱으로서 실사용 가치가 확실하기 때문입니다.

권장 알림 옵션:

- 마감 7일 전
- 마감 3일 전
- 마감 1일 전
- 마감 당일
- 사용자가 직접 지정한 custom reminder

구현 방식:

- `UNUserNotificationCenter`로 로컬 알림 사용
- 서버 푸시 알림은 1차에서 제외
- 선택된 대표 deadline과 즐겨찾기 deadline 위주로 예약

주의할 점:

- iOS에는 pending local notification 개수 제한이 있으므로 모든 학회 전체 deadline을 무작정 예약하지 않습니다.
- 알림 권한은 앱 첫 실행이 아니라 사용자가 알림 기능을 켤 때 요청합니다.

## 10. 데이터 업데이트 설계

현재 macOS 앱은 GitHub의 `data/conferences.json`을 수동으로 가져와 캐시합니다. 모바일 앱도 같은 정책으로 시작합니다.

1차 정책:

- 앱 번들에 기본 `conferences.json` 포함
- 사용자가 `데이터 업데이트 확인`을 누르면 GitHub raw JSON 다운로드
- 성공하면 로컬 캐시에 저장
- 실패하면 기존 캐시 또는 번들 데이터 사용
- 자동 크롤링과 서버 운영은 제외

Widget과 공유하기 위해 모바일 앱에서는 캐시 위치를 App Group container로 옮길 수 있게 설계합니다.

코어 변경 후보:

- `ConferenceDataUpdater`의 cache URL 주입을 모바일에서도 명확히 사용
- `SettingsStore`와 `UserDeadlineStore`가 App Group `UserDefaults`를 받을 수 있게 유지
- 데이터 검증을 `DdayCoreChecks`와 모바일 테스트에서 함께 사용

## 11. 설정과 상태 관리

공유 상태:

- 선택된 대표 deadline
- 사용자 지정 D-Day 목록
- 즐겨찾기 deadline 목록
- 언어 설정
- 마지막 데이터 업데이트 시각

macOS 전용 상태:

- 메뉴바 표시 모드
- 메뉴바 배지 스타일

모바일 전용 상태:

- 위젯 표시 대상
- 알림 설정
- 즐겨찾기
- 앱 첫 실행 여부

권장 저장소:

- 일반 앱 설정: `UserDefaults`
- Widget 공유 설정: App Group `UserDefaults`
- 캐시 JSON: App Group container file
- 민감정보: 없음

## 12. App Store 출시 준비

Apple Developer Program 등록 전에도 Simulator 기반 개발과 기능 검증은 가능합니다. 다만 TestFlight, App Store Connect 업로드, App Store 심사 제출은 Apple Developer Program 등록 후 진행합니다.

등록 전 가능한 항목:

- iPhone/iPad Simulator 실행
- Widget Simulator 테스트
- 로컬 알림 테스트
- GitHub에 소스 코드 Push
- 앱 이름, 아이콘, 스크린샷, 설명 초안 준비

등록 후 필요한 항목:

- Apple Developer 계정
- Xcode 설치
- Xcode에 Apple Account 로그인
- Bundle ID 등록
- App Store Connect 앱 레코드 생성
- Signing & Capabilities 설정
- TestFlight 업로드
- App Review 제출

권장 Bundle ID 초안:

```text
dev.mindw.DdayMobile
dev.mindw.DdayMobile.DdayWidgets
group.dev.mindw.Dday
```

현재 macOS 앱의 Bundle ID와 충돌을 피하기 위해 모바일 앱은 별도 Bundle ID로 시작합니다. 실제 App Store 등록 전에 최종 이름과 Bundle ID는 한 번 더 확정합니다.

App Store 메타데이터 초안:

- 앱 이름: Dday
- 부제: AI Conference Deadlines
- 카테고리: Productivity 또는 Education
- 개인정보: 수집 없음
- 주요 설명:
  - AI/ML/CV/NLP 학회 데드라인 추적
  - AoE deadline을 로컬 시간 기준으로 표시
  - 홈 화면/잠금 화면 위젯 지원
  - 사용자 지정 D-Day 지원

## 13. 심사 리스크와 대응

예상 리스크:

- 학회명과 약어 사용
- 날짜 정보 정확성
- 앱이 너무 단순하다는 판단
- 외부 데이터 업데이트 URL 사용

대응:

- 각 학회마다 공식 출처 URL을 표시
- 앱 설명에 "official conference source links are provided" 성격을 명확히 표기
- 데이터 정확성 고지와 업데이트 날짜 표시
- 위젯, 알림, 사용자 지정 D-Day로 충분한 앱 기능 제공
- 개인정보 수집 없음 정책 유지

## 14. CI/CD 전략

현재 GitHub Actions는 macOS 앱 빌드와 Release 자동화를 담당합니다.

모바일 앱 추가 후 단계별 CI:

1. `swift run DdayCoreChecks`
2. `swift build`
3. iOS Simulator build
4. Widget extension build
5. 수동 TestFlight 업로드
6. 나중에 App Store Connect API 기반 자동 업로드 검토

초기에는 App Store 업로드를 자동화하지 않습니다. 인증서, provisioning profile, App Store Connect API key 관리가 필요하므로 첫 출시는 Xcode Organizer에서 수동으로 진행하는 편이 안전합니다.

자동화는 출시 경험이 한두 번 쌓인 뒤에 다음 후보를 검토합니다.

- `xcodebuild archive`
- `xcodebuild -exportArchive`
- App Store Connect API key
- GitHub Actions secrets
- fastlane

## 15. 개발 단계

### Phase 0. 준비

- Xcode 설치
- Xcode 실행 후 추가 컴포넌트 설치
- Apple Developer 계정 로그인
- `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
- `xcodebuild -version` 확인

### Phase 1. 구조 만들기

- `Package.swift`에 iOS 플랫폼 추가
- `Apps/Mobile` 아래 Xcode 프로젝트 생성
- `DdayMobile` 앱 타깃 생성
- `DdayWidgets` Widget extension 생성
- Xcode 프로젝트에서 local package로 `DdayCore` 연결

### Phase 2. 모바일 MVP

- Home 화면
- Conference 목록
- Conference 상세
- 대표 deadline 선택
- 사용자 지정 D-Day 목록
- 데이터 업데이트 확인
- 한국어/영어 기본 문구

### Phase 3. Widget

- App Group 설정
- 선택된 deadline 공유
- Small/Medium/Lock Screen Widget 구현
- 앱에서 설정 변경 시 widget reload

### Phase 4. 알림

- 알림 권한 요청
- 7일/3일/1일/당일 local notification
- 알림 설정 화면

### Phase 5. TestFlight

등록 전 준비:

- TestFlight 준비 문서 작성
- Bundle ID와 App Group 확인
- Archive 스크립트 준비
- Simulator에서 iPhone/iPad/Widget/알림 기능 검증

등록 후 실행:

- App Store Connect 앱 레코드 생성
- Xcode Signing & Capabilities에서 Team 설정
- App Group을 App target과 Widget target에 연결
- Archive
- Upload
- Internal testing
- 친구와 연구실 구성원 대상 external testing

### Phase 6. App Store 출시

- 스크린샷
- 앱 설명
- 개인정보 응답
- Review notes
- 첫 심사 제출

## 16. Codex와 함께 작업하는 방식

사용자님은 Python과 LLM 연구에 익숙하시고 Swift는 처음이므로, 작업 방식은 다음처럼 가져갑니다.

사용자님이 주로 결정할 것:

- 어떤 기능이 연구자에게 실제로 유용한지
- 앱 이름, 설명, 스크린샷 톤
- 학회 데이터의 우선순위
- 알림 기본값
- App Store 공개 범위

Codex가 주로 담당할 것:

- Swift/SwiftUI 코드 작성
- Xcode 프로젝트 구조 정리
- 빌드 에러 분석
- 테스트와 CI 정리
- App Store 제출 체크리스트 작성
- Swift 개념을 Python 관점에서 설명

같이 익히면 좋은 Swift 개념:

- `struct`, `enum`, `protocol`
- `Codable`
- `async/await`
- `@State`, `@Binding`, `@Environment`
- `NavigationStack`, `NavigationSplitView`
- Xcode target, scheme, bundle identifier
- signing, provisioning, TestFlight

Python 관점에서 보면 `Conference` 같은 Swift `struct`는 `dataclass`나 Pydantic model에 가깝고, `Codable`은 JSON decode/encode 규칙을 타입에 붙이는 방식으로 이해하면 쉽습니다.

## 17. 다음 실행 항목

바로 다음 단계는 코드 변경보다 개발 환경 준비입니다.

1. App Store에서 Xcode 설치
2. Xcode를 한 번 직접 실행해 라이선스와 추가 컴포넌트 설치
3. Apple Developer 계정 등록 완료
4. Xcode에 Apple Account 로그인
5. 터미널에서 Xcode 활성화 확인

확인 명령:

```bash
xcodebuild -version
xcode-select -p
```

그 다음 Codex가 할 작업:

1. `Package.swift`를 iOS 호환으로 조정
2. `Apps/Mobile` 프로젝트 생성
3. `DdayCore`를 모바일 앱에 연결
4. iPhone/iPad 첫 화면을 빌드 가능한 상태로 구현
5. Simulator에서 실행 확인

## 18. 열어둘 결정

아래 결정은 실제 Xcode 프로젝트를 만들기 전에 한 번 더 확정합니다.

- 앱 이름을 `Dday`로 유지할지, `AI Deadline Dday`처럼 더 설명적으로 갈지
- Bundle ID 최종값
- 최소 iOS 버전
- Widget을 1차 MVP에 반드시 포함할지
- 알림을 TestFlight 전에 넣을지, TestFlight 피드백 후 넣을지
- Mac App Store까지 같이 갈지, macOS는 GitHub 배포를 유지할지

현재 추천은 다음과 같습니다.

- 앱 이름: `Dday`
- 최소 iOS: iOS 17
- iPhone/iPad: Universal app 하나로 개발
- Widget: 1차 MVP 포함
- 알림: TestFlight 전까지 포함
- macOS: 당분간 GitHub 배포 유지, Developer ID notarization 적용

## 19. Phase 1 구현 기록

2026-06-04에 Phase 1을 시작했습니다.

완료한 내용:

- `Package.swift`에 iOS 17 플랫폼 지원 추가
- `Apps/Mobile/DdayMobile.xcodeproj` 추가
- `Apps/Mobile/DdayMobile` SwiftUI 앱 소스 추가
- Xcode shared scheme `DdayMobile` 추가
- 앱 타깃에서 루트 Swift Package의 `DdayCore`를 local package로 연결
- `data/conferences.json`을 모바일 앱 리소스로 포함
- iPhone/iPad Universal app 설정

현재 모바일 앱 뼈대:

- `Home` 탭
  - 번들 conference JSON 로드
  - 가장 가까운 upcoming primary deadline 표시
  - D-Day 계산은 `DdayCore.DeadlineCalculator` 사용
- `Conferences` 탭
  - Machine Learning, Computer Vision, NLP, General AI 카테고리
  - 학회 목록
  - 학회 상세와 공식 홈페이지/출처 링크

검증 명령:

```bash
swift build
swift run DdayCoreChecks
xcodebuild -project Apps/Mobile/DdayMobile.xcodeproj \
  -scheme DdayMobile \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

다음 단계:

- 실제 iPhone/iPad Simulator에서 실행 확인
- 모바일 UI를 Phase 2 수준으로 확장
- 사용자 선택 deadline 저장
- 사용자 지정 D-Day 입력
- 데이터 업데이트 버튼
- 한국어/영어 문구 정리

## 20. Phase 2 구현 기록

2026-06-04에 Phase 2 모바일 MVP 구현을 시작했습니다.

완료한 내용:

- `Home`, `Conferences`, `Custom`, `Settings` 4탭 구조 추가
- Home 화면에서 사용자가 선택한 메인 D-Day를 우선 표시
- 메인 D-Day가 없으면 가장 가까운 upcoming deadline 자동 표시
- 학회별 primary deadline이 이미 지난 경우에도 `Upcoming`에 `D+`가 섞이지 않도록 다음 upcoming deadline을 선택
- 학회 상세 화면에서 각 deadline을 메인 D-Day로 설정하는 버튼 추가
- 선택한 conference/custom deadline을 `UserDefaults`에 저장
- 사용자 지정 D-Day 추가/삭제 화면 추가
- 사용자 지정 D-Day 추가 시 AoE 또는 로컬 타임존 선택
- Settings 화면 추가
- Settings에서 언어를 System/English/Korean 중 선택
- Settings에서 학회 목록 업데이트 확인 버튼 추가
- 한국어/영어 주요 화면 문구 추가
- 지난 학회는 category별 `Past Conferences` 섹션으로 분리

검증 명령:

```bash
swift build
swift run DdayCoreChecks
xcodebuild -project Apps/Mobile/DdayMobile.xcodeproj \
  -scheme DdayMobile \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  -quiet build
```

다음 보완 후보:

- 실제 Simulator에서 iPhone/iPad 레이아웃 스크린샷 확인
- 선택된 deadline을 위젯과 공유할 App Group 구조 준비
- 모바일 전용 앱 아이콘 asset catalog 추가
- Custom D-Day 편집 기능
- 업데이트 성공 시 마지막 업데이트 시각 표시
- App Store용 Privacy 문구와 스크린샷 초안 준비

## 21. Phase 3 구현 기록

2026-06-04에 Phase 3 WidgetKit 구현을 시작했습니다.

완료한 내용:

- `DdayWidgets` WidgetKit extension target 추가
- 앱 타깃에 Widget extension embed 설정 추가
- 앱과 위젯 모두 App Group entitlement 추가
- App Group identifier 초안: `group.dev.mindw.Dday`
- 앱이 선택한 메인 D-Day를 위젯용 snapshot으로 저장하는 구조 추가
- 위젯이 App Group `UserDefaults`에서 snapshot을 읽도록 구현
- 앱에서 메인 D-Day 선택, 사용자 D-Day 삭제, 데이터 업데이트 시 Widget timeline reload 요청
- 홈 화면 위젯 family 추가
  - `systemSmall`
  - `systemMedium`
- 잠금화면 위젯 family 추가
  - `accessoryCircular`
  - `accessoryRectangular`
  - `accessoryInline`
- 위젯 placeholder/preview 추가

주요 파일:

```text
Apps/Mobile/Shared/MobileWidgetSnapshotStore.swift
Apps/Mobile/DdayWidgets/DdayWidgetsBundle.swift
Apps/Mobile/DdayWidgets/DeadlineWidget.swift
Apps/Mobile/DdayWidgets/Info.plist
Apps/Mobile/DdayMobile/DdayMobile.entitlements
Apps/Mobile/DdayWidgets/DdayWidgets.entitlements
```

현재 위젯 표시:

- Small: 학회명, D-Day, deadline label
- Medium: 학회명, deadline label, 로컬 날짜, D-Day
- Lock Screen Circular: 학회명과 D-Day
- Lock Screen Rectangular: 학회명, D-Day, deadline label
- Lock Screen Inline: `AAAI D-62` 형태

검증 명령:

```bash
swift build
swift run DdayCoreChecks
xcodebuild -project Apps/Mobile/DdayMobile.xcodeproj \
  -scheme DdayMobile \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  -quiet build
```

주의할 점:

- 실제 기기와 TestFlight에서 App Group을 사용하려면 Apple Developer portal에서 `group.dev.mindw.Dday`를 등록하고 앱/위젯 App ID에 연결해야 합니다.
- iOS/iPadOS 위젯은 추가했지만, WatchOS complication은 아직 별도 Watch app/extension target이 필요합니다.
- WidgetKit은 시스템이 갱신 주기를 제어하므로 분 단위 실시간 갱신은 보장되지 않습니다. 앱에서 선택을 바꿀 때는 timeline reload를 요청합니다.

다음 보완 후보:

- Xcode에서 위젯 preview와 Simulator 위젯 추가 화면 확인
- App Group identifier를 최종 bundle/team 정책에 맞춰 확정
- 위젯 디자인을 실제 잠금화면/홈화면 스크린샷 기준으로 다듬기
- WatchOS target 추가 여부 결정

## 22. Phase 4 구현 기록

2026-06-04에 Phase 4 local notification reminder 구현을 시작했습니다.

완료한 내용:

- `UserNotifications` 기반 로컬 알림 스케줄러 추가
- Settings 화면에 `Enable deadline reminders` 토글 추가
- 사용자가 알림을 켤 때만 알림 권한 요청
- 알림을 끄면 Dday가 예약한 pending notification만 제거
- 메인 D-Day와 사용자 지정 D-Day를 대상으로 알림 예약
- 명시적으로 선택한 D-Day가 없어도 Home/Widget에 보이는 자동 메인 D-Day를 알림 대상으로 사용
- 같은 deadline이 메인 D-Day와 사용자 D-Day 목록에 중복될 때 중복 예약 방지
- 알림 window 추가
  - 7일 전
  - 3일 전
  - 1일 전
  - 마감 당일
- deadline, custom deadline, 데이터 업데이트, 언어 설정이 바뀌면 알림 재예약
- 한국어/영어 알림 제목과 본문 지원

주요 파일:

```text
Apps/Mobile/DdayMobile/App/MobileNotificationScheduler.swift
Apps/Mobile/DdayMobile/App/MobileAppModel.swift
Apps/Mobile/DdayMobile/Screens/SettingsScreen.swift
Apps/Mobile/DdayMobile/App/MobileAppText.swift
```

현재 알림 정책:

- 7일/3일/1일 전 알림은 로컬 시간 기준 오전 9시에 예약
- 마감 당일 알림은 로컬 시간 기준 오전 9시에 예약
- 만약 마감 시간이 오전 9시보다 빠르면 마감 1시간 전으로 조정
- 이미 지난 알림 시간은 예약하지 않음
- 서버 푸시 알림은 사용하지 않음

검증 명령:

```bash
swift build
swift run DdayCoreChecks
xcodebuild -project Apps/Mobile/DdayMobile.xcodeproj \
  -scheme DdayMobile \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  -quiet build
```

다음 보완 후보:

- 실제 Simulator에서 알림 권한 요청과 예약 메시지 확인
- 사용자가 알림 window를 직접 고르게 하기
- 알림 목록/다음 알림 시간 표시
- TestFlight 전 실제 기기에서 notification delivery 확인
