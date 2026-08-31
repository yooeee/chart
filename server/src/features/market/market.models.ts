export interface MarketMover {
  symbol: string;
  name: string;
  price: number;
  changePercent: number;
  group: 'index' | 'stock' | 'crypto';
}

export interface MarketSummary {
  configured: boolean;
  source: string;
  isDemo: boolean;
  updatedAt: string;
  indices: MarketMover[];
  gainers: MarketMover[];
  losers: MarketMover[];
  crypto: MarketMover[];
}

export interface EconomicEvent {
  id: string;
  scheduledAt: string;
  country: string;
  importance: 'low' | 'medium' | 'high';
  title: string;
  previous?: string;
  forecast?: string;
}

export interface EconomicCalendar {
  configured: boolean;
  source: string;
  isDemo: boolean;
  events: EconomicEvent[];
}
