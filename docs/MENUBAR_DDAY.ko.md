# macOS 상단바 D-Day

[English](MENUBAR_DDAY.md) · [한국어 README](../README.ko.md)

macOS 앱은 선택한 학회 데드라인을 상단바에 직접 표시합니다. 캘린더 앱을 계속 열지 않아도 중요한 마감 하나를 항상 볼 수 있게 하는 것이 핵심입니다.

<p align="center">
  <img src="assets/menubar-preview.png" alt="AAAI D-62를 표시하는 Dday 상단바 배지" width="320">
</p>

## 주요 기능

- 선택한 학회를 `AAAI D-42`, `D-Day`, `H-10`, `M-59`, `D+3` 형식으로 표시
- AoE 등 원본 마감 시간대를 사용자 로컬 시간대로 변환
- 상단바에 학회 이름을 표시할지 선택
- 텍스트형과 배지형 상단바 스타일 지원
- 한국어, 영어, 시스템 언어 모드 지원
- Machine Learning, Computer Vision, NLP, General AI 카테고리 제공
- 지난 학회는 삭제하지 않고 Past Conferences 섹션에 유지
- 목록에 없는 개인 마감용 사용자 D-Day 지원
- GitHub 공개 학회 목록 수동 업데이트
- GitHub macOS 릴리즈용 Sparkle 업데이트 확인 지원

## 설치

1. [GitHub Releases](https://github.com/mindw96/AI-Conference-Dday/releases/latest)에서 최신 DMG를 받습니다.
2. DMG를 엽니다.
3. `Dday.app`을 `Applications`로 드래그합니다.
4. `Dday.app`을 실행합니다.

현재 공개 macOS 빌드는 Developer ID로 서명 및 공증되어 있습니다.

## 로컬 빌드

```bash
swift build
./scripts/build_app.sh
open build/Dday.app
```

## 릴리즈 빌드

Developer ID 배포는 아래 스크립트를 사용합니다.

```bash
./scripts/notarize_release.sh v1.1.1
```

릴리즈 스크립트는 다음 파일을 생성합니다.

```text
dist/Dday-vX.Y.Z.dmg
dist/Dday-vX.Y.Z.zip
dist/appcast.xml
```

`appcast.xml`은 GitHub Release에 함께 업로드되며, 이후 macOS 앱의 업데이트 확인에 사용됩니다.

## 데이터

macOS 앱에는 기본 학회 목록이 포함되어 있고, 사용자가 수동 업데이트를 실행하면 최신 목록을 캐시합니다. 업데이트가 실패하면 마지막 캐시 목록 또는 번들 목록을 계속 사용합니다.

## 개인정보

macOS 앱은 설정을 로컬 `UserDefaults`에 저장합니다. 계정, 분석 도구, 추적 기능을 사용하지 않습니다.
