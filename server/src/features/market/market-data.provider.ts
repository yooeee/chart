import { EconomicCalendar, MarketSummary } from './market.models';

export const MARKET_DATA_PROVIDER = Symbol('MARKET_DATA_PROVIDER');

export interface AlertMarketSnapshot {
  price: number;
  indicatorSignal?: 'buy' | 'sell';
}

export interface MarketDataProvider {
  readonly supportsAlertEvaluation: boolean;
  getSummary(): Promise<MarketSummary>;
  getEconomicCalendar(): Promise<EconomicCalendar>;
  getAlertSnapshot(symbol: string, indicatorId?: string): Promise<AlertMarketSnapshot | null>;
}
