import 'market_symbol.dart';

abstract final class MarketSymbolCatalog {
  static const symbols = <MarketSymbol>[
    MarketSymbol(
      ticker: 'NEXON',
      displayName: '넥슨게임즈',
      exchange: 'KOSDAQ',
      providerSymbol: '225570',
      providerExchange: 'KRX',
    ),
    MarketSymbol(
      ticker: 'NAVER',
      displayName: 'NAVER',
      exchange: 'KOSPI',
      providerSymbol: '035420',
      providerExchange: 'KRX',
    ),
    MarketSymbol(
      ticker: 'SAMSUNG',
      displayName: '삼성전자',
      exchange: 'KOSPI',
      providerSymbol: '005930',
      providerExchange: 'KRX',
    ),
    MarketSymbol(
      ticker: 'NVDA',
      displayName: 'NVIDIA',
      exchange: 'NASDAQ',
      providerSymbol: 'NVDA',
      providerExchange: 'NASDAQ',
    ),
  ];

  static MarketSymbol findByTicker(String ticker) {
    return symbols.firstWhere(
      (marketSymbol) => marketSymbol.ticker == ticker,
      orElse: () => symbols.first,
    );
  }
}
