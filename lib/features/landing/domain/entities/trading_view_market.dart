class TradingViewMarket {
  const TradingViewMarket({
    required this.ticker,
    required this.displayName,
    required this.exchange,
    required this.tradingViewSymbol,
  });

  final String ticker;
  final String displayName;
  final String exchange;
  final String tradingViewSymbol;

  static const markets = <TradingViewMarket>[
    TradingViewMarket(
      ticker: 'BTCUSD',
      displayName: 'Bitcoin',
      exchange: 'BINANCE',
      tradingViewSymbol: 'BINANCE:BTCUSDT',
    ),
    TradingViewMarket(
      ticker: 'ETHUSD',
      displayName: 'Ethereum',
      exchange: 'BINANCE',
      tradingViewSymbol: 'BINANCE:ETHUSDT',
    ),
    TradingViewMarket(
      ticker: 'SAMSUNG',
      displayName: '삼성전자 추종 선물',
      exchange: 'BINANCE FUTURES',
      tradingViewSymbol: 'BINANCE:SAMSUNGUSDT.P',
    ),
    TradingViewMarket(
      ticker: 'SKHYNIX',
      displayName: 'SK하이닉스 추종 선물',
      exchange: 'BINANCE FUTURES',
      tradingViewSymbol: 'BINANCE:SKHYNIXUSDT.P',
    ),
  ];
}
