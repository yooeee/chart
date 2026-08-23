# Pulse Chart

Flutter 기반의 반응형 주식 차트 워크스페이스입니다. Web, iOS, Android에서 같은 차트 UI를 사용하도록 외부 차트 렌더링 라이브러리 없이 `CustomPainter`로 캔들 차트와 지표 패널을 그립니다.

## 현재 포함된 기능

- Twelve Data의 실제 OHLCV 데이터 연동
- 마우스 크로스헤어와 터치 핀치 줌
- 추세 리본, RSI Pulse, MACD Momentum, Bollinger Squeeze, Volume Pressure, Smart Flow
- 지표별 개별 토글 및 지표 설명 패널
- 데스크톱 2열 / 모바일 단일 열 반응형 레이아웃
- Nexon의 화이트·근검정·일렉트릭 그린에서 영감을 받은 sharp UI

## 실행

```bash
flutter create --platforms=web,ios,android .
flutter pub get
flutter run -d chrome --dart-define=TWELVE_DATA_API_KEY=YOUR_KEY
flutter run -d ios --dart-define=TWELVE_DATA_API_KEY=YOUR_KEY
flutter run -d android --dart-define=TWELVE_DATA_API_KEY=YOUR_KEY
```

APK를 직접 만들 때도 같은 값을 전달합니다.

```bash
flutter build apk --release --dart-define=TWELVE_DATA_API_KEY=YOUR_KEY
```

API 키가 없으면 앱은 데모 데이터로 전환하지 않고 `TWELVE_DATA_API_KEY` 설정 오류를 표시합니다. API 키를 `lib/` 파일이나 GitHub 커밋에 저장하지 마세요. `--dart-define`로 클라이언트에 넣은 키는 Web 번들과 APK에서 노출될 수 있으므로 내부 테스트용으로만 사용하고, 배포 서비스에서는 서버 프록시의 환경변수로 보호해야 합니다.

`main`에 push하면 GitHub Actions가 Android release APK를 빌드합니다. 빌드가 성공하면 Actions 실행 화면의 `pulse-chart-release-apk` 아티팩트에서 APK를 받을 수 있습니다. 수동 실행은 `Actions > Flutter checks > Run workflow`에서 할 수 있습니다.

현재 화면은 `TwelveDataMarketDataSource`에서 받은 OHLCV를 사용합니다. 데이터 공급자의 거래소별 제공 범위와 지연 여부는 계정 플랜에 따라 달라집니다. `DemoMarketDataSource`는 네트워크 없이 지표 테스트를 실행하기 위한 fixture로만 남아 있습니다.

Twelve Data 공식 문서: https://twelvedata.com/docs

> 투자 판단을 위한 신호가 아니라 UI·계산 구조를 검증하기 위한 앱입니다.
