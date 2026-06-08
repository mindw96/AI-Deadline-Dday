# TestFlight Preparation Guide

작성일: 2026-06-04

이 문서는 `Dday` iPhone/iPad 앱을 TestFlight로 배포하기 위한 준비 절차입니다.

현재 Apple Developer Program 등록과 기본 signing 설정은 완료된 상태입니다. 앱 구조, Bundle ID, Widget, App Group, 알림 기능은 TestFlight와 App Store 제출 준비 단계로 넘어갈 수 있게 구현되어 있습니다.

## 1. 현재 가능한 것

Apple Developer Program 등록 전에도 다음 작업은 가능합니다.

- iPhone/iPad Simulator 실행
- 앱 기본 기능 테스트
- WidgetKit Simulator 테스트
- 로컬 알림 동작 확인
- Xcode 프로젝트 구조 정리
- GitHub에 소스 코드 Push

무료 Apple Account로 실제 iPhone에 직접 설치하는 개인 테스트도 가능하지만 제한이 있습니다. Apple 공식 문서 기준으로 Personal Team의 App ID, 테스트 기기, provisioning profile은 일정 기간 후 만료될 수 있습니다.

## 2. 등록 후 가능한 것

Apple Developer Program 등록 후 다음 작업이 가능해집니다.

- App Store Connect 앱 레코드 생성
- TestFlight 빌드 업로드
- 내부 테스터 초대
- 외부 테스터 초대
- App Store 심사 제출
- 고급 capability와 distribution signing 사용

`Dday`는 Widget과 앱이 데이터를 공유하기 위해 App Group을 사용합니다. 따라서 실제 기기와 TestFlight 배포에서는 App Group capability가 App ID에 등록되어 있어야 합니다.

## 3. 현재 프로젝트 식별자

현재 Xcode 프로젝트의 Bundle ID와 App Group은 다음과 같습니다.

```text
App target:    dev.mindw.DdayMobile
Widget target: dev.mindw.DdayMobile.DdayWidgets
App Group:     group.dev.mindw.Dday
```

App Store Connect 앱 레코드는 App target의 Bundle ID인 `dev.mindw.DdayMobile`로 생성합니다. Widget target은 같은 앱 안에 포함되는 extension입니다.

## 4. Developer Program 등록 후 Xcode 설정

1. Xcode에서 `Apps/Mobile/DdayMobile.xcodeproj`를 엽니다.
2. 왼쪽 상단 Project Navigator에서 `DdayMobile` 프로젝트를 선택합니다.
3. `DdayMobile` target을 선택합니다.
4. `Signing & Capabilities` 탭을 엽니다.
5. `Team`을 사용자님의 Apple Developer Team으로 선택합니다.
6. Bundle Identifier가 `dev.mindw.DdayMobile`인지 확인합니다.
7. `+ Capability`에서 `App Groups`를 추가합니다.
8. `group.dev.mindw.Dday`를 체크합니다.
9. `DdayWidgets` target에서도 같은 방식으로 `Team`과 `App Groups`를 설정합니다.

두 target 모두 같은 Team과 같은 App Group을 사용해야 앱과 위젯이 같은 데이터를 읽을 수 있습니다.

## 5. App Store Connect 앱 레코드 초안

App Store Connect에서 새 앱을 만들 때 권장 값은 다음과 같습니다.

```text
Platform: iOS
Name: Dday
Primary Language: Korean
Bundle ID: dev.mindw.DdayMobile
SKU: dday-ai-deadlines-ios
User Access: Full Access
```

카테고리는 첫 출시 기준으로 `Productivity`가 가장 자연스럽고, 대안으로 `Education`을 고려할 수 있습니다.

## 6. Archive와 업로드

Developer Program 등록과 Xcode signing 설정이 끝난 뒤에는 Xcode에서 다음 순서로 진행합니다.

1. Scheme을 `DdayMobile`로 선택합니다.
2. 실행 대상에서 `Any iOS Device` 또는 실제 기기를 선택합니다.
3. 메뉴에서 `Product > Archive`를 실행합니다.
4. Organizer가 열리면 생성된 archive를 선택합니다.
5. `Distribute App`을 누릅니다.
6. `App Store Connect`를 선택합니다.
7. Upload를 진행합니다.

명령줄로 archive만 만들고 싶을 때는 다음 스크립트를 사용할 수 있습니다.

```bash
./scripts/archive_ios_app.sh
```

archive를 App Store Connect 업로드용 `.ipa`로 내보낼 때는 다음 스크립트를 사용합니다.

```bash
./scripts/export_ios_app_store.sh
```

Team ID를 명시해야 할 때는 다음처럼 실행합니다.

```bash
DEVELOPMENT_TEAM=<YOUR_TEAM_ID> ./scripts/archive_ios_app.sh
```

`<YOUR_TEAM_ID>`는 공개 저장소에 커밋하지 않습니다. Xcode가 `DdayMobile.xcodeproj/project.pbxproj`에 `DEVELOPMENT_TEAM = ...;` 값을 자동으로 넣을 수 있는데, 공개 저장소에서는 이 줄을 제거한 상태로 유지합니다.

기본적으로 `-allowProvisioningUpdates`를 켜고 실행하므로, Xcode에 로그인된 Apple Developer 계정이 App ID와 provisioning profile을 자동으로 만들 수 있습니다.

이 스크립트는 signing 설정이 끝난 뒤에 사용하는 보조 도구입니다. Developer Program 등록 전에는 실패하는 것이 정상입니다. 등록 후에도 Xcode가 아직 유료 Team을 인식하지 못하거나, 개발용 profile 생성을 위한 실제 기기가 등록되지 않은 경우 실패할 수 있습니다.

현재 확인된 1차 차단 사례:

- `Signing requires a development team`: Xcode target의 Team이 비어 있음
- `Your team has no devices`: 개발용 provisioning profile을 만들 실제 기기가 아직 등록되지 않음
- `conflicting provisioning settings`: 자동 개발 서명과 수동 배포 서명 옵션이 충돌함

## 7. TestFlight 운영 순서

1. App Store Connect에서 앱 레코드를 만듭니다.
2. Xcode에서 archive를 업로드합니다.
3. Apple의 빌드 처리가 끝날 때까지 기다립니다.
4. TestFlight 탭에서 내부 테스트 그룹을 만듭니다.
5. 내부 테스터로 본인 계정과 가까운 사용자 몇 명을 추가합니다.
6. 기본 기능, 위젯, 잠금 화면 위젯, 알림을 확인합니다.
7. 안정화 후 외부 테스트 그룹을 만듭니다.
8. 외부 테스트용 Beta App Review를 통과한 뒤 친구나 연구실 구성원에게 초대 링크를 공유합니다.

첫 TestFlight는 내부 테스트부터 시작하는 편이 좋습니다. 외부 테스트는 Apple의 beta review가 한 번 더 들어가므로, 앱 설명과 테스트 안내가 준비된 뒤 진행합니다.

## 8. 결제 전 체크리스트

Developer Program 결제 전까지는 다음을 끝내두면 좋습니다.

- iPhone Simulator 기능 테스트
- iPad Simulator 기능 테스트
- 홈 화면 위젯 테스트
- 잠금 화면 위젯 테스트
- 알림 예약 테스트
- App Icon 최종 후보 준비
- 앱 이름과 부제 확정
- App Store 스크린샷 후보 준비
- 개인정보 수집 없음 정책 문구 확정

현재 기능 구현은 TestFlight 직전 단계까지 와 있습니다. 결제가 완료되면 남는 일은 주로 Apple 계정, signing, App Store Connect 설정입니다.

## 9. 공식 문서

- [Choosing a Membership](https://developer.apple.com/support/compare-memberships/)
- [Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)
- [TestFlight Overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/overview-of-testing-with-testflight/)
