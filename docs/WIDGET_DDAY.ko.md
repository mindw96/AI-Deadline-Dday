# iPhone/iPad 위젯 D-Day

[English](WIDGET_DDAY.md) · [한국어 README](../README.ko.md)

iPhone과 iPad 앱의 핵심은 위젯입니다. 사용자가 중요한 마감을 하나 선택하면, Dday가 홈 화면과 잠금화면 위젯에 그 D-Day를 표시합니다.

<p align="center">
  <img src="assets/widget-home-preview.png" alt="AAAI D-43을 표시하는 Dday iPhone 홈 화면 위젯" width="260">
  <img src="assets/widget-lock-preview.png" alt="AAAI D-43을 표시하는 Dday iPhone 잠금화면 위젯" width="260">
</p>

## 주요 기능

- 학회 상세 화면에서 메인 D-Day 선택
- 앱 홈 화면에 선택한 D-Day 표시
- App Group container를 통해 앱과 WidgetKit이 선택한 마감 공유
- 홈 화면 위젯 지원:
  - Small
  - Medium
  - Large
  - iPad Extra Large
- 잠금화면 위젯 지원:
  - Circular
  - Rectangular
- 위젯 배경색과 글씨색 설정
- 개인 마감용 사용자 D-Day
- 메인 D-Day와 사용자 D-Day의 로컬 알림 예약
- 한국어, 영어, 시스템 언어 모드

## 사용 흐름

1. `Dday`를 엽니다.
2. `학회` 탭으로 이동합니다.
3. 카테고리와 학회를 선택합니다.
4. 추적할 deadline을 선택합니다.
5. 메인 D-Day로 설정합니다.
6. 홈 화면 또는 잠금화면에 Dday 위젯을 추가합니다.

위젯은 앱이 로컬에 저장한 공유 snapshot을 읽어 표시됩니다.

## 위젯 외형

앱 설정에서 위젯 외형을 선택할 수 있습니다.

- 배경색: 시스템, 흰색, 검정, 네이비
- 글씨색: 자동, 검정, 흰색

시스템 배경은 iOS 위젯 기본 스타일을 따릅니다. 커스텀 색상은 홈 화면 위젯에 적용됩니다.

## 알림

마감 알림을 켜면 Dday가 메인 D-Day와 사용자 D-Day에 대해 로컬 알림을 예약합니다.

- 7일 전
- 3일 전
- 1일 전
- 당일

Dday는 서버 푸시 알림을 사용하지 않습니다.

## 로컬 빌드

Xcode 프로젝트를 엽니다.

```text
Apps/Mobile/DdayMobile.xcodeproj
```

Simulator 또는 실제 기기 빌드는 `DdayMobile` scheme을 사용합니다.

## 개인정보

모바일 앱과 위젯은 App Group container를 통해 데이터를 로컬로 공유합니다. 사용자 D-Day, 선택한 마감, 위젯 외형, 알림 설정은 기기에 저장됩니다.
