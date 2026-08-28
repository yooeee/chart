enum IndicatorType {
  trendRibbon,
  rsiPulse,
  macdMomentum,
  bollingerSqueeze,
  volumePressure,
  smartFlow,
}

extension IndicatorTypeDetails on IndicatorType {
  String get displayName {
    switch (this) {
      case IndicatorType.trendRibbon:
        return 'Adaptive Trend Ribbon';
      case IndicatorType.rsiPulse:
        return 'RSI Pulse';
      case IndicatorType.macdMomentum:
        return 'MACD Momentum';
      case IndicatorType.bollingerSqueeze:
        return 'Bollinger Squeeze';
      case IndicatorType.volumePressure:
        return 'Volume Pressure';
      case IndicatorType.smartFlow:
        return 'Smart Flow';
    }
  }

  String get shortName {
    switch (this) {
      case IndicatorType.trendRibbon:
        return 'TREND';
      case IndicatorType.rsiPulse:
        return 'RSI';
      case IndicatorType.macdMomentum:
        return 'MACD';
      case IndicatorType.bollingerSqueeze:
        return 'BOLL';
      case IndicatorType.volumePressure:
        return 'V-PRESS';
      case IndicatorType.smartFlow:
        return 'FLOW';
    }
  }

  String get description {
    switch (this) {
      case IndicatorType.trendRibbon:
        return 'EMA 21/55의 방향과 변동성을 한 줄로 읽습니다.';
      case IndicatorType.rsiPulse:
        return '14기간 RSI와 5기간 신호선의 속도를 봅니다.';
      case IndicatorType.macdMomentum:
        return '추세 방향과 모멘텀 변화를 히스토그램으로 표시합니다.';
      case IndicatorType.bollingerSqueeze:
        return '밴드 폭의 수축·확장을 통해 변동성 국면을 추적합니다.';
      case IndicatorType.volumePressure:
        return '가격 움직임에 실린 거래량의 매수·매도 압력을 계산합니다.';
      case IndicatorType.smartFlow:
        return '거래량 방향성과 현재 거래량 이탈을 함께 읽습니다.';
    }
  }

  bool get isOverlay =>
      this == IndicatorType.trendRibbon ||
      this == IndicatorType.bollingerSqueeze;
}
