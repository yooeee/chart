class MarketSymbol {
  const MarketSymbol({
    required this.ticker,
    required this.displayName,
    required this.exchange,
    required this.providerSymbol,
    required this.providerExchange,
  });

  final String ticker;
  final String displayName;
  final String exchange;

  /// Symbol identifiers used by the selected market-data provider.
  final String providerSymbol;
  final String providerExchange;
}
