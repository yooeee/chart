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
      displayName: '삼성전자',
      exchange: 'KRX',
      tradingViewSymbol: 'KRX:005930',
    ),
    TradingViewMarket(
      ticker: 'SKHYNIX',
      displayName: 'SK하이닉스',
      exchange: 'KRX',
      tradingViewSymbol: 'KRX:000660',
    ),
    TradingViewMarket(
      ticker: 'NAVER',
      displayName: 'NAVER',
      exchange: 'KRX',
      tradingViewSymbol: 'KRX:035420',
    ),
    TradingViewMarket(
      ticker: 'NVDA',
      displayName: 'NVIDIA',
      exchange: 'NASDAQ',
      tradingViewSymbol: 'NASDAQ:NVDA',
    ),
    TradingViewMarket(
      ticker: 'TSLA',
      displayName: 'Tesla',
      exchange: 'NASDAQ',
      tradingViewSymbol: 'NASDAQ:TSLA',
    ),
    TradingViewMarket(
      ticker: 'INTC',
      displayName: 'Intel',
      exchange: 'NASDAQ',
      tradingViewSymbol: 'NASDAQ:INTC',
    ),
    TradingViewMarket(
      ticker: 'BA',
      displayName: 'Boeing',
      exchange: 'NYSE',
      tradingViewSymbol: 'NYSE:BA',
    ),
    TradingViewMarket(
      ticker: 'KOSPI',
      displayName: 'KOSPI',
      exchange: 'KRX',
      tradingViewSymbol: 'KRX:KOSPI',
    ),
    TradingViewMarket(
      ticker: 'NDX',
      displayName: 'NASDAQ 100',
      exchange: 'NASDAQ',
      tradingViewSymbol: 'NASDAQ:NDX',
    ),
    TradingViewMarket(
      ticker: 'SPX',
      displayName: 'S&P 500',
      exchange: 'S&P',
      tradingViewSymbol: 'SP:SPX',
    ),
  ];

  static TradingViewMarket findBySymbol(String symbol) {
    return markets.firstWhere(
      (market) => market.tradingViewSymbol == symbol,
      orElse: () => markets.first,
    );
  }
}
