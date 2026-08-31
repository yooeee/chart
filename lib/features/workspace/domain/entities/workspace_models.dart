enum ChartThemePreference { light, dark }

enum PriceAlertType {
  priceAbove,
  priceBelow,
  indicatorBuy,
  indicatorSell,
}

class ChartWorkspacePreferences {
  const ChartWorkspacePreferences({
    required this.symbol,
    required this.interval,
    required this.theme,
    required this.activeIndicators,
    required this.updatedAt,
  });

  final String symbol;
  final String interval;
  final ChartThemePreference theme;
  final Set<String> activeIndicators;
  final DateTime updatedAt;

  ChartWorkspacePreferences copyWith({
    String? symbol,
    String? interval,
    ChartThemePreference? theme,
    Set<String>? activeIndicators,
    DateTime? updatedAt,
  }) {
    return ChartWorkspacePreferences(
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
      theme: theme ?? this.theme,
      activeIndicators: activeIndicators ?? this.activeIndicators,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object> toJson() => {
        'symbol': symbol,
        'interval': interval,
        'theme': theme.name,
        'activeIndicators': activeIndicators.toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChartWorkspacePreferences.fromJson(Map<String, dynamic> json) {
    return ChartWorkspacePreferences(
      symbol: json['symbol'] as String? ?? 'BINANCE:BTCUSDT',
      interval: json['interval'] as String? ?? 'D',
      theme: ChartThemePreference.values.firstWhere(
        (theme) => theme.name == json['theme'],
        orElse: () => ChartThemePreference.light,
      ),
      activeIndicators: ((json['activeIndicators'] as List<dynamic>?) ?? const [])
          .whereType<String>()
          .toSet(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static ChartWorkspacePreferences get initial => ChartWorkspacePreferences(
        symbol: 'BINANCE:BTCUSDT',
        interval: 'D',
        theme: ChartThemePreference.light,
        activeIndicators: const {},
        updatedAt: DateTime.now(),
      );
}

class SavedPriceAlert {
  const SavedPriceAlert({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.enabled,
    required this.createdAt,
    this.targetPrice,
    this.indicatorId,
  });

  final String id;
  final String name;
  final String symbol;
  final PriceAlertType type;
  final double? targetPrice;
  final String? indicatorId;
  final bool enabled;
  final DateTime createdAt;

  SavedPriceAlert copyWith({bool? enabled}) => SavedPriceAlert(
        id: id,
        name: name,
        symbol: symbol,
        type: type,
        targetPrice: targetPrice,
        indicatorId: indicatorId,
        enabled: enabled ?? this.enabled,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
        'type': type.name,
        'targetPrice': targetPrice,
        'indicatorId': indicatorId,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedPriceAlert.fromJson(Map<String, dynamic> json) {
    return SavedPriceAlert(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      type: PriceAlertType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => PriceAlertType.priceAbove,
      ),
      targetPrice: (json['targetPrice'] as num?)?.toDouble(),
      indicatorId: json['indicatorId'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class PulseAccount {
  const PulseAccount({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  factory PulseAccount.fromJson(Map<String, dynamic> json) => PulseAccount(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String? ?? json['email'] as String,
        photoUrl: json['photoUrl'] as String?,
      );
}

class PulseNotification {
  const PulseNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;

  PulseNotification copyWith({bool? read}) => PulseNotification(
        id: id,
        title: title,
        message: message,
        createdAt: createdAt,
        read: read ?? this.read,
      );

  factory PulseNotification.fromJson(Map<String, dynamic> json) => PulseNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        read: json['read'] as bool? ?? false,
      );
}

class MarketSnapshot {
  const MarketSnapshot({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
  });

  final String symbol;
  final String name;
  final double price;
  final double changePercent;

  factory MarketSnapshot.fromJson(Map<String, dynamic> json) => MarketSnapshot(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        changePercent: (json['changePercent'] as num).toDouble(),
      );
}

class MarketSummaryData {
  const MarketSummaryData({
    required this.configured,
    required this.source,
    required this.isDemo,
    required this.indices,
    required this.gainers,
    required this.losers,
    required this.crypto,
  });

  final bool configured;
  final String source;
  final bool isDemo;
  final List<MarketSnapshot> indices;
  final List<MarketSnapshot> gainers;
  final List<MarketSnapshot> losers;
  final List<MarketSnapshot> crypto;

  factory MarketSummaryData.fromJson(Map<String, dynamic> json) {
    List<MarketSnapshot> readList(String key) =>
        ((json[key] as List<dynamic>?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(MarketSnapshot.fromJson)
            .toList();
    return MarketSummaryData(
      configured: json['configured'] as bool? ?? false,
      source: json['source'] as String? ?? 'NOT CONFIGURED',
      isDemo: json['isDemo'] as bool? ?? false,
      indices: readList('indices'),
      gainers: readList('gainers'),
      losers: readList('losers'),
      crypto: readList('crypto'),
    );
  }

  static const demo = MarketSummaryData(
    configured: true,
    source: 'PULSE DEMO DATA',
    isDemo: true,
    indices: [
      MarketSnapshot(symbol: 'KRX:KOSPI', name: 'KOSPI', price: 2684.21, changePercent: .42),
      MarketSnapshot(symbol: 'NASDAQ:NDX', name: 'NASDAQ 100', price: 19612.3, changePercent: .71),
      MarketSnapshot(symbol: 'SP:SPX', name: 'S&P 500', price: 5634.18, changePercent: .31),
    ],
    gainers: [
      MarketSnapshot(symbol: 'NASDAQ:NVDA', name: 'NVIDIA', price: 128.4, changePercent: 4.81),
      MarketSnapshot(symbol: 'NASDAQ:TSLA', name: 'Tesla', price: 238.7, changePercent: 3.26),
    ],
    losers: [
      MarketSnapshot(symbol: 'NASDAQ:INTC', name: 'Intel', price: 23.1, changePercent: -2.86),
      MarketSnapshot(symbol: 'NYSE:BA', name: 'Boeing', price: 174.5, changePercent: -1.94),
    ],
    crypto: [
      MarketSnapshot(symbol: 'BINANCE:BTCUSDT', name: 'Bitcoin', price: 64200, changePercent: 1.38),
      MarketSnapshot(symbol: 'BINANCE:ETHUSDT', name: 'Ethereum', price: 2740, changePercent: -.22),
    ],
  );
}

class EconomicCalendarEvent {
  const EconomicCalendarEvent({
    required this.id,
    required this.scheduledAt,
    required this.country,
    required this.importance,
    required this.title,
    this.previous,
    this.forecast,
  });

  final String id;
  final DateTime scheduledAt;
  final String country;
  final String importance;
  final String title;
  final String? previous;
  final String? forecast;

  factory EconomicCalendarEvent.fromJson(Map<String, dynamic> json) => EconomicCalendarEvent(
        id: json['id'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        country: json['country'] as String,
        importance: json['importance'] as String,
        title: json['title'] as String,
        previous: json['previous'] as String?,
        forecast: json['forecast'] as String?,
      );
}

class EconomicCalendarData {
  const EconomicCalendarData({
    required this.configured,
    required this.source,
    required this.isDemo,
    required this.events,
  });

  final bool configured;
  final String source;
  final bool isDemo;
  final List<EconomicCalendarEvent> events;

  factory EconomicCalendarData.fromJson(Map<String, dynamic> json) => EconomicCalendarData(
        configured: json['configured'] as bool? ?? false,
        source: json['source'] as String? ?? 'NOT CONFIGURED',
        isDemo: json['isDemo'] as bool? ?? false,
        events: ((json['events'] as List<dynamic>?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(EconomicCalendarEvent.fromJson)
            .toList(),
      );

  static EconomicCalendarData createDemo() {
    final now = DateTime.now();
    return EconomicCalendarData(
      configured: true,
      source: 'PULSE DEMO DATA',
      isDemo: true,
      events: [
        EconomicCalendarEvent(id: 'demo-cpi', scheduledAt: now.add(const Duration(days: 1)), country: 'US', importance: 'high', title: '소비자물가지수(CPI)', previous: '3.1%', forecast: '3.0%'),
        EconomicCalendarEvent(id: 'demo-rate', scheduledAt: now.add(const Duration(days: 2)), country: 'US', importance: 'high', title: '기준금리 결정'),
        EconomicCalendarEvent(id: 'demo-employment', scheduledAt: now.add(const Duration(days: 4)), country: 'US', importance: 'medium', title: '비농업 고용지표'),
      ],
    );
  }
}

class IndicatorGuideEntry {
  const IndicatorGuideEntry({
    required this.id,
    required this.name,
    required this.category,
    required this.formula,
    required this.summary,
    required this.interpretation,
    required this.caution,
  });

  final String id;
  final String name;
  final String category;
  final String formula;
  final String summary;
  final String interpretation;
  final String caution;

  static const entries = <IndicatorGuideEntry>[
    IndicatorGuideEntry(id: 'trendRibbon', name: 'Adaptive Trend Ribbon', category: '추세 / 오버레이', formula: 'EMA 21 / EMA 55', summary: '두 지수이동평균의 방향과 간격으로 추세 강도를 읽습니다.', interpretation: '단기선이 장기선 위에서 함께 상승하면 상승 추세, 아래에서 함께 하락하면 하락 추세로 해석합니다.', caution: '횡보장에서는 교차 신호가 잦아 다른 모멘텀 지표와 함께 확인해야 합니다.'),
    IndicatorGuideEntry(id: 'rsiPulse', name: 'RSI Pulse', category: '모멘텀 / 오실레이터', formula: 'RSI 14 + Signal 5', summary: 'RSI와 신호선의 속도 변화를 함께 표시합니다.', interpretation: '과매수·과매도 숫자보다 RSI와 신호선의 교차 및 기울기 전환을 확인합니다.', caution: '강한 추세에서는 과열 구간이 오래 유지될 수 있습니다.'),
    IndicatorGuideEntry(id: 'macdMomentum', name: 'MACD Momentum', category: '모멘텀 / 히스토그램', formula: 'EMA 12 / 26 / Signal 9', summary: '추세 방향과 모멘텀 변화를 선과 히스토그램으로 보여줍니다.', interpretation: '히스토그램이 0선을 넘고 확대되면 해당 방향의 모멘텀이 강화되는 것으로 봅니다.', caution: '후행 지표이므로 급격한 반전에서는 신호가 늦을 수 있습니다.'),
    IndicatorGuideEntry(id: 'bollingerSqueeze', name: 'Bollinger Squeeze', category: '변동성 / 오버레이', formula: 'SMA 20 / ±2σ', summary: '밴드 폭의 수축과 확장으로 변동성 국면을 추적합니다.', interpretation: '밴드가 좁아진 뒤 거래량과 함께 확장되는 방향을 돌파 후보로 관찰합니다.', caution: '수축 자체는 방향을 알려주지 않으므로 가격 구조를 함께 봐야 합니다.'),
    IndicatorGuideEntry(id: 'volumePressure', name: 'Volume Pressure', category: '거래량 / 압력', formula: '14 Period Pressure', summary: '가격 움직임에 실린 매수·매도 거래량 압력을 계산합니다.', interpretation: '가격 상승과 매수 압력 증가가 같이 나타나는지 확인해 움직임의 신뢰도를 봅니다.', caution: '거래량 품질이 낮은 종목에서는 왜곡될 수 있습니다.'),
    IndicatorGuideEntry(id: 'smartFlow', name: 'Smart Flow', category: '수급 / 편차', formula: '20 Period Flow + Z-score', summary: '거래량 방향성과 현재 거래량 이탈을 함께 읽습니다.', interpretation: '20기간 흐름과 현재 거래량 편차가 같은 방향이면 수급 집중 가능성을 관찰합니다.', caution: '뉴스성 급등락은 일시적 이상치일 수 있어 지속 여부를 확인해야 합니다.'),
  ];
}
