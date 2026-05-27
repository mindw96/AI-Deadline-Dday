# Dday 전체 설계도

## 1. 프로젝트 개요

`Dday`는 macOS 메뉴바에 학회 마감일까지 남은 기간을 표시하는 가벼운 데스크톱 앱입니다. 사용자가 날짜를 매번 직접 입력하는 방식이 아니라, 앱이 제공하는 학회 목록에서 관심 학회를 선택하면 선택된 학회의 주요 마감일을 메뉴바에 `D-42`처럼 표시합니다.

초기 목표는 연구자, 대학원생, 논문 작성자가 자주 확인하는 학회 데드라인을 작은 메뉴바 앱으로 빠르게 확인할 수 있게 하는 것입니다. 장기적으로는 공개 배포 가능한 오픈소스 앱으로 발전시키며, 학회 데이터 갱신과 기여 흐름을 명확하게 관리합니다.

## 2. 핵심 사용자

- AI, ML, CV, NLP, HCI, Systems 등 학회 마감일을 자주 확인해야 하는 연구자
- 여러 학회 일정을 동시에 추적해야 하는 대학원생과 연구실 구성원
- 웹사이트나 캘린더를 열지 않고 메뉴바에서 대표 데드라인만 빠르게 보고 싶은 사용자
- 공개된 학회 데이터에 직접 기여하고 싶은 오픈소스 사용자

## 3. 제품 원칙

- 메뉴바에서 바로 읽히는 정보가 가장 중요합니다.
- 사용자는 날짜를 직접 입력하기보다 신뢰할 수 있는 학회 목록에서 선택합니다.
- 데이터 출처와 갱신 시점을 투명하게 보여줍니다.
- 기본 기능은 오프라인에서도 동작해야 합니다.
- 공개 배포를 전제로 개인정보 수집을 최소화합니다.
- 앱은 작고 빠르게 유지하되, 데이터 관리 구조는 확장 가능하게 둡니다.

## 4. 1차 기능 범위

### 포함할 기능

- macOS 메뉴바에 선택한 학회 마감일까지의 D-Day 표시
- 학회 목록 보기
- 메인으로 표시할 학회 또는 마감일 선택
- 학회별 주요 날짜 표시
  - Abstract deadline
  - Full paper deadline
  - Supplementary deadline
  - Notification date
  - Conference date
- 학회 검색 및 분야 필터
- 데이터 출처 URL 표시
- 로컬 설정 저장
- 앱 종료 메뉴

### 1차에서 제외할 기능

- 계정 로그인
- 서버 동기화
- 사용자 행동 분석
- 푸시 알림
- 캘린더 자동 연동
- 학회 웹사이트 자동 크롤링
- App Store 배포

## 5. 장기 기능 후보

- 마감 임박 알림
- 여러 학회를 메뉴바에서 순환 표시
- iCloud 또는 파일 기반 설정 동기화
- Apple Calendar 내보내기
- ICS 파일 생성
- GitHub 기반 학회 데이터 자동 업데이트
- 사용자 커스텀 학회 추가
- 학회 데이터 PR 검증 자동화
- 분야별 프리셋
- 다국어 지원

## 6. macOS 앱 구조

초기 앱은 Swift 기반 macOS 네이티브 앱으로 개발합니다.

- UI 프레임워크: AppKit 중심
- 메뉴바 표시: `NSStatusItem`
- 설정 창: SwiftUI 또는 AppKit
- 데이터 파싱: Swift `Codable`
- 로컬 설정 저장: `UserDefaults`
- 날짜 계산: `Calendar`, `DateComponents`

메뉴바 앱은 SwiftUI 단독 앱보다 AppKit의 `NSStatusItem`이 자연스럽습니다. 설정 화면은 SwiftUI로 만들 수 있지만, 초기 버전에서는 AppKit과 SwiftUI를 혼합할 수 있도록 구조를 열어둡니다.

## 7. 데이터 구조

학회 데이터는 앱 코드와 분리된 JSON 파일로 관리합니다. 초기에는 앱 번들에 포함된 정적 JSON을 사용하고, 이후 원격 업데이트 파일을 추가할 수 있도록 설계합니다.

### Conference

```json
{
  "id": "neurips-2026",
  "name": "NeurIPS",
  "fullName": "Conference on Neural Information Processing Systems",
  "year": 2026,
  "field": ["machine-learning", "artificial-intelligence"],
  "location": "TBD",
  "websiteUrl": "https://neurips.cc/",
  "sourceUrl": "https://neurips.cc/Conferences/2026/CallForPapers",
  "sourceCheckedAt": "2026-05-27",
  "timezone": "AoE",
  "deadlines": [
    {
      "id": "full-paper",
      "label": "Full Paper Deadline",
      "date": "2026-05-15",
      "time": "20:00",
      "timezone": "AoE",
      "type": "submission",
      "isPrimary": true
    }
  ]
}
```

### Deadline Type

- `abstract`
- `submission`
- `supplementary`
- `notification`
- `camera-ready`
- `conference-start`
- `conference-end`

## 8. D-Day 계산 규칙

날짜 표시는 사용자가 직관적으로 이해할 수 있어야 합니다.

- 마감 전: `D-42`
- 마감 당일: `D-Day`
- 마감 후: `D+3`
- 마감 시간이 있는 경우 해당 타임존 기준으로 계산
- 타임존이 `AoE`인 경우 Anywhere on Earth 기준으로 처리
- 날짜만 있고 시간이 없는 경우 해당 날짜의 끝을 기준으로 처리

초기 버전에서는 계산 정확성을 우선해 단순하게 구현합니다. AoE 처리와 지역 시간 변환은 별도 유틸리티로 분리해 테스트 가능하게 만듭니다.

## 9. UI 설계

### 메뉴바

메뉴바에는 선택된 대표 마감일을 짧게 표시합니다.

예시:

- `NeurIPS D-42`
- `ICML D-Day`
- `ACL D+3`

표시 문자열이 너무 길어질 수 있으므로 앱 설정에서 표시 모드를 선택할 수 있게 합니다.

- 짧게: `D-42`
- 학회명 포함: `NeurIPS D-42`
- 날짜 포함: `NeurIPS 5/15`

### 메뉴 클릭 시

메뉴바 아이템을 클릭하면 드롭다운 메뉴를 표시합니다.

- 현재 선택된 학회와 마감일
- 남은 일수
- 마감 날짜와 타임존
- 다른 학회 선택
- 전체 목록 열기
- 데이터 출처 열기
- 설정
- 종료

### 학회 목록 창

초기 공개 버전에서는 작은 목록 창을 제공합니다.

- 검색 입력
- 분야 필터
- 연도 필터
- 학회 리스트
- 마감일 리스트
- 메인 표시로 설정 버튼
- 출처 URL 열기

## 10. 로컬 설정

사용자 설정은 `UserDefaults`에 저장합니다.

저장할 값:

- 선택된 학회 ID
- 선택된 deadline ID
- 메뉴바 표시 모드
- 분야 필터 기본값
- 마지막 데이터 갱신 시각
- 알림 사용 여부

개인정보나 사용자 계정 정보는 저장하지 않습니다.

## 11. 데이터 업데이트 전략

### 1단계: 앱 번들 정적 데이터

- `Resources/conferences.json` 파일을 앱에 포함
- 앱은 실행 시 번들 JSON을 읽음
- 네트워크 없이 동작

### 2단계: GitHub 원격 JSON 업데이트

- GitHub repository에 `data/conferences.json` 공개
- 앱이 사용자의 명시적 동의 후 최신 데이터 확인
- 다운로드한 데이터는 Application Support 폴더에 캐시
- 실패하면 번들 데이터를 사용

### 3단계: 데이터 기여 워크플로

- 학회 데이터 변경은 Pull Request로 관리
- JSON schema로 형식 검증
- 출처 URL 필수
- `sourceCheckedAt` 필수
- 중복 ID 검사
- 날짜 형식 검사

## 12. 공개 배포 계획

### 초기 배포

- GitHub 공개 저장소
- README에 설치 및 빌드 방법 제공
- GitHub Releases에 `.app.zip` 또는 `.dmg` 제공
- 코드 서명은 초기에는 ad-hoc 또는 개발자 로컬 빌드 중심

### 안정화 이후

- Apple Developer ID 서명
- Notarization 적용
- Sparkle 기반 자동 업데이트 검토
- Homebrew Cask 배포 검토
- App Store 배포는 별도 정책 검토 후 결정

## 13. 저장소 구조

```text
Dday/
  README.md
  LICENSE
  PROJECT_DESIGN.md
  Package.swift
  Sources/
    DdayApp/
      App/
        AppDelegate.swift
        MenuBarController.swift
      Models/
        Conference.swift
        Deadline.swift
      Services/
        ConferenceStore.swift
        DeadlineCalculator.swift
        SettingsStore.swift
      Views/
        ConferenceListView.swift
        SettingsView.swift
      Resources/
        conferences.json
  Tests/
    DdayAppTests/
      DeadlineCalculatorTests.swift
      ConferenceStoreTests.swift
  data/
    conferences.json
    schema.json
  docs/
    DATA_GUIDE.md
    RELEASE_GUIDE.md
    PRIVACY.md
```

## 14. 라이선스와 데이터 정책

앱 코드는 공개 저장소에 올릴 경우 MIT 또는 Apache-2.0을 우선 검토합니다.

학회 데이터는 단순 사실 정보이지만, 각 학회 사이트의 내용을 그대로 복제하지 않도록 주의합니다. 저장소에는 다음 정보만 최소한으로 유지합니다.

- 학회명
- 연도
- 분야 태그
- 날짜와 타임존
- 공식 출처 URL
- 확인 날짜

학회 설명문이나 CFP 본문을 복사하지 않습니다.

## 15. 개인정보 정책

초기 버전은 개인정보를 수집하지 않습니다.

- 계정 없음
- 서버 전송 없음
- 분석 SDK 없음
- 광고 없음
- 로컬 설정만 저장

원격 데이터 업데이트 기능이 추가될 경우, 앱이 GitHub raw file 또는 release asset을 요청할 수 있다는 점을 개인정보 문서에 명시합니다.

## 16. 품질 관리

### 테스트 대상

- D-Day 계산
- AoE 타임존 처리
- 날짜 파싱
- JSON 데이터 로딩
- 누락 필드 처리
- 선택된 학회 저장과 복원

### 수동 검증

- 앱 실행 시 메뉴바 표시 확인
- 메뉴 클릭 동작 확인
- 학회 선택 후 메뉴바 문구 갱신 확인
- 앱 재실행 후 선택 유지 확인
- 네트워크 없이 실행 확인

## 17. 개발 단계

### Phase 0: 설계

- 전체 설계 문서 작성
- 앱 이름과 저장소 이름 확정
- 초기 지원 학회 범위 결정
- 라이선스 후보 결정

### Phase 1: 로컬 프로토타입

- Swift 메뉴바 앱 생성
- 정적 JSON 데이터 로딩
- 선택된 학회 D-Day 표시
- 로컬 설정 저장

### Phase 2: 사용 가능한 MVP

- 학회 목록 창 추가
- 검색과 필터 추가
- 출처 URL 열기
- 기본 README 작성
- 테스트 추가

### Phase 3: 공개 준비

- 저장소 구조 정리
- 라이선스 추가
- 개인정보 문서 추가
- 데이터 기여 가이드 작성
- 릴리스 빌드 절차 정리

### Phase 4: 공개 배포

- GitHub repository 공개
- 첫 release 생성
- 사용자 피드백 수집
- 데이터 업데이트 프로세스 운영

## 18. 초기 의사결정 필요 항목

- 앱 이름을 `Dday`로 유지할지, 학회 특화 이름으로 바꿀지
- 초기 분야를 AI/ML 중심으로 할지, 전체 CS 학회로 넓힐지
- 첫 공개 버전을 GitHub Release로만 배포할지
- 로그인 시 자동 실행을 1차에 포함할지
- 알림 기능을 1차에서 제외할지 포함할지
- 라이선스를 MIT로 할지 Apache-2.0으로 할지

## 19. 현재 권장 방향

초기에는 범위를 작게 유지하는 것이 좋습니다.

- 앱 이름: `Dday`
- 플랫폼: macOS 전용
- 기술: Swift + AppKit + 일부 SwiftUI
- 데이터: 번들 JSON
- 초기 학회 범위: AI/ML/NLP/CV 주요 학회 10개 내외
- 공개 방식: GitHub 공개 저장소 + GitHub Release
- 1차 핵심: 메뉴바 표시, 학회 선택, 출처 확인

이 방향이면 짧은 시간 안에 실제로 실행 가능한 앱을 만들 수 있고, 공개 프로젝트로 확장할 때도 데이터와 코드 구조가 무너지지 않습니다.
