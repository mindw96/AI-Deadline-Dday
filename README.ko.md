# Dday

Dday는 AI 학회 데드라인을 Apple 기기에서 빠르게 확인할 수 있게 도와주는 앱입니다.

Mac에서는 상단바에 선택한 D-Day를 계속 띄우고, iPhone과 iPad에서는 홈 화면과 잠금화면 위젯으로 가장 중요한 마감을 볼 수 있습니다.

[English README](README.md)

## 미리보기

<p align="center">
  <img src="docs/assets/menubar-preview.png" alt="AAAI D-62를 표시하는 Dday macOS 상단바 배지" width="320">
  <img src="docs/assets/widget-home-preview.png" alt="AAAI D-43을 표시하는 Dday iPhone 홈 화면 위젯" width="220">
  <img src="docs/assets/widget-lock-preview.png" alt="AAAI D-43을 표시하는 Dday iPhone 잠금화면 위젯" width="220">
</p>

## 플랫폼별 안내

| 경험 | 플랫폼 | 문서 |
| --- | --- | --- |
| 상단바 D-Day | macOS | [macOS 상단바 D-Day](docs/MENUBAR_DDAY.ko.md) |
| 위젯 D-Day | iPhone, iPad | [iPhone/iPad 위젯 D-Day](docs/WIDGET_DDAY.ko.md) |

## 주요 기능

- Machine Learning, Computer Vision, NLP, General AI로 나뉜 AI 학회 데드라인 목록
- AoE 마감과 사용자 로컬 시간대 기준 D-Day 계산
- 앱과 위젯에 표시할 메인 D-Day 직접 선택
- 목록에 없는 개인 마감용 사용자 D-Day
- 한국어, 영어, 시스템 언어 설정
- 로컬 우선 설정과 데이터 저장
- GitHub 공개 데이터셋 기반 학회 목록 수동 업데이트

## 배포 방식

- iPhone/iPad: App Store를 통해 배포합니다.
- macOS: 서명 및 공증된 GitHub Release로 배포합니다.

현재 macOS 릴리즈는 Apple Silicon Mac에서 실행됩니다.

macOS 앱은
[최신 GitHub Release](https://github.com/mindw96/AI-Conference-Dday/releases/latest)에서 받을 수 있습니다.

## 저장소 구조

```text
Dday/
  Apps/
    Mobile/                 # iPhone/iPad 앱과 WidgetKit 확장
  Checks/
    DdayCoreChecks/          # 가벼운 검증 실행기
  Sources/
    DdayCore/                # 공통 모델, 데이터 로딩, D-Day 계산 로직
    DdayApp/                 # macOS 상단바 앱
  data/
    conferences.json         # 공개 학회 데드라인 데이터셋
  docs/
  scripts/
```

`DdayCore`는 Apple 플랫폼들이 공유하는 핵심 로직입니다. macOS 앱, iPhone/iPad 앱, 위젯은 같은 코어 데이터를 각 플랫폼에 맞게 보여주는 역할을 합니다.

## 개발

Swift package 빌드:

```bash
swift build
```

공통 데이터와 계산 로직 검증:

```bash
swift build --product DdayCoreChecks
.build/debug/DdayCoreChecks
```

macOS 앱 번들 빌드:

```bash
./scripts/build_app.sh
```

iPhone/iPad 앱은 Xcode에서 엽니다.

```text
Apps/Mobile/DdayMobile.xcodeproj
```

릴리즈 관련 문서:

- [macOS 서명 및 공증](docs/MACOS_NOTARIZATION.md)
- [릴리즈 가이드](docs/RELEASE_GUIDE.md)
- [TestFlight 준비 가이드](docs/TESTFLIGHT_PREP.md)

## 데이터

공개 학회 목록은 아래 파일에서 관리합니다.

```text
data/conferences.json
```

각 학회 항목에는 출처 URL과 출처를 확인한 날짜가 포함되어야 합니다.

## 개인정보

Dday는 로컬 우선 앱입니다. 계정이 필요 없고, 분석 도구나 추적 SDK를 포함하지 않습니다. 자세한 내용은 [Privacy](docs/PRIVACY.md)를 참고해 주세요.

## 라이선스

TBD.
