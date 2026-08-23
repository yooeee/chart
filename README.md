# Pulse Chart

Flutter 기반의 반응형 주식 차트 워크스페이스입니다. Web, iOS, Android에서 같은 차트 UI를 사용하도록 외부 차트 렌더링 라이브러리 없이 `CustomPainter`로 캔들 차트와 지표 패널을 그립니다.

## 현재 포함된 기능

- 데모 시장 데이터로 동작하는 캔들 차트
- 마우스 크로스헤어와 터치 핀치 줌
- 추세 리본, RSI Pulse, MACD Momentum, Bollinger Squeeze, Volume Pressure, Smart Flow
- 지표별 개별 토글 및 지표 설명 패널
- 데스크톱 2열 / 모바일 단일 열 반응형 레이아웃
- Nexon의 화이트·근검정·일렉트릭 그린에서 영감을 받은 sharp UI

## 실행

```bash
flutter create --platforms=web,ios,android .
flutter pub get
flutter run -d chrome
flutter run -d ios
flutter run -d android
```

현재 데이터는 `lib/models/market_data.dart`의 deterministic demo feed입니다. 실제 거래소 또는 시세 API를 연결할 때는 `DemoMarketDataSource`를 실시간 데이터 소스로 교체하면 화면과 지표 계산 코드는 그대로 사용할 수 있습니다.

> 투자 판단을 위한 신호가 아니라 UI·계산 구조를 검증하기 위한 샘플 앱입니다.
