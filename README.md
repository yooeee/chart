# Pulse Chart

Flutter 기반의 반응형 시장 차트 워크스페이스입니다. Web에서는 TradingView
Advanced Chart 위젯을 직접 임베드해 삼성전자, 비트코인, NAVER, NVDA, NEXON의
실제 TradingView 차트를 표시합니다.

## Web 차트

- TradingView Advanced Chart 위젯 사용
- API 키 없이 브라우저에서 TradingView 시장 데이터 로드
- 삼성전자(`KRX:005930`)와 비트코인(`BINANCE:BTCUSDT`) 선택
- 15분, 1시간, 일봉, 주봉 인터벌 선택
- Web 화면에는 커스텀 보조지표를 표시하지 않음
- 데스크톱·태블릿·모바일 폭에 맞춰 반응형으로 동작

## 실행

```bash
flutter create --platforms=web,ios,android .
flutter pub get
flutter run -d chrome
```

Web 차트는 TradingView 위젯이 브라우저에서 데이터를 요청하므로
`TWELVE_DATA_API_KEY`가 필요하지 않습니다.

## GitHub Pages

`.github/workflows/deploy-web.yml`이 `main` push 시 Flutter Web을 빌드하고
GitHub Pages에 배포합니다.

1. 저장소 `Settings > Pages > Build and deployment > Source`를 `GitHub Actions`로 설정
2. `Actions > Deploy Flutter Web to GitHub Pages`를 실행하거나 `main`에 push
3. 배포 완료 후 `https://yooeee.github.io/chart/`에서 확인

TradingView 차트의 실시간성·지연 여부는 거래소와 TradingView의 데이터 정책에
따릅니다. 차트 내부의 거래소·심볼 변경 기능도 TradingView 위젯에서 제공합니다.

## 네이티브 앱

iOS·Android에는 기존 Flutter 네이티브 차트 경로가 남아 있습니다. 해당 경로는
Twelve Data API 키를 실행 시 전달해야 합니다.

```bash
flutter run -d android --dart-define=TWELVE_DATA_API_KEY=YOUR_KEY
flutter build apk --release --dart-define=TWELVE_DATA_API_KEY=YOUR_KEY
```

API 키는 저장소에 커밋하지 않습니다. GitHub Actions APK 빌드는 키 없이도 수행되지만,
키가 없는 네이티브 실행 화면에서는 Twelve Data 설정 안내가 표시됩니다.

## 참고

- TradingView Advanced Chart widget: https://www.tradingview.com/widget-docs/widgets/charts/advanced-chart/
- TradingView 위젯은 TradingView의 제공 조건과 거래소 데이터 지연 정책을 따릅니다.
- 투자 판단을 위한 신호가 아니라 UI와 차트 연동을 검증하기 위한 앱입니다.


## 프로젝트 구조

- `features/chart/domain`: 시장 엔티티, Repository 계약, UseCase, 순수 지표 계산
- `features/chart/data`: Twelve Data 원격 데이터소스, 응답 모델, Repository 구현
- `features/chart/presentation`: 차트 페이지, Controller, 화면 위젯
- `features/landing`: 소개 페이지와 TradingView 화면
- `core` 및 `app`: 공통 색상과 앱 구성

화면 계층은 UseCase와 도메인 계약만 참조하고, API 구현체는 Data 계층에 격리되어 있습니다.
