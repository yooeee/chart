import { Injectable } from '@nestjs/common';

import { MarketDataProvider } from './market-data.provider';
import { EconomicCalendar, MarketSummary } from './market.models';

@Injectable()
export class UnconfiguredMarketDataProvider implements MarketDataProvider {
  readonly supportsAlertEvaluation = false;

  async getSummary(): Promise<MarketSummary> {
    return {
      configured: false,
      source: 'NOT CONFIGURED',
      isDemo: false,
      updatedAt: new Date().toISOString(),
      indices: [],
      gainers: [],
      losers: [],
      crypto: [],
    };
  }

  async getEconomicCalendar(): Promise<EconomicCalendar> {
    return {
      configured: false,
      source: 'NOT CONFIGURED',
      isDemo: false,
      events: [],
    };
  }

  async getAlertSnapshot(): Promise<null> {
    return null;
  }
}
