import { Inject, Injectable } from '@nestjs/common';

import { MARKET_DATA_PROVIDER } from './market-data.provider';
import type { MarketDataProvider } from './market-data.provider';

@Injectable()
export class MarketService {
  constructor(
    @Inject(MARKET_DATA_PROVIDER)
    private readonly marketDataProvider: MarketDataProvider,
  ) {}

  getSummary() {
    return this.marketDataProvider.getSummary();
  }

  getEconomicCalendar() {
    return this.marketDataProvider.getEconomicCalendar();
  }
}
