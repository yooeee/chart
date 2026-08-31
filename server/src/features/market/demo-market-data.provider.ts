import { Injectable } from '@nestjs/common';

import { MarketDataProvider } from './market-data.provider';
import { EconomicCalendar, MarketSummary } from './market.models';

@Injectable()
export class DemoMarketDataProvider implements MarketDataProvider {
  readonly supportsAlertEvaluation = false;

  async getSummary(): Promise<MarketSummary> {
    return {
      configured: true,
      source: 'PULSE DEMO DATA',
      isDemo: true,
      updatedAt: new Date().toISOString(),
      indices: [
        { symbol: 'KRX:KOSPI', name: 'KOSPI', price: 2684.21, changePercent: 0.42, group: 'index' },
        {
          symbol: 'NASDAQ:NDX',
          name: 'NASDAQ 100',
          price: 19612.3,
          changePercent: 0.71,
          group: 'index',
        },
        { symbol: 'SP:SPX', name: 'S&P 500', price: 5634.18, changePercent: 0.31, group: 'index' },
      ],
      gainers: [
        {
          symbol: 'NASDAQ:NVDA',
          name: 'NVIDIA',
          price: 128.4,
          changePercent: 4.81,
          group: 'stock',
        },
        { symbol: 'NASDAQ:TSLA', name: 'Tesla', price: 238.7, changePercent: 3.26, group: 'stock' },
      ],
      losers: [
        { symbol: 'NASDAQ:INTC', name: 'Intel', price: 23.1, changePercent: -2.86, group: 'stock' },
        { symbol: 'NYSE:BA', name: 'Boeing', price: 174.5, changePercent: -1.94, group: 'stock' },
      ],
      crypto: [
        {
          symbol: 'BINANCE:BTCUSDT',
          name: 'Bitcoin',
          price: 64200,
          changePercent: 1.38,
          group: 'crypto',
        },
        {
          symbol: 'BINANCE:ETHUSDT',
          name: 'Ethereum',
          price: 2740,
          changePercent: -0.22,
          group: 'crypto',
        },
      ],
    };
  }

  async getEconomicCalendar(): Promise<EconomicCalendar> {
    const base = new Date();
    const eventAt = (days: number, hour: number): string => {
      const date = new Date(base);
      date.setUTCDate(base.getUTCDate() + days);
      date.setUTCHours(hour, 0, 0, 0);
      return date.toISOString();
    };
    return {
      configured: true,
      source: 'PULSE DEMO DATA',
      isDemo: true,
      events: [
        {
          id: 'demo-cpi',
          scheduledAt: eventAt(1, 12),
          country: 'US',
          importance: 'high',
          title: '소비자물가지수(CPI)',
          previous: '3.1%',
          forecast: '3.0%',
        },
        {
          id: 'demo-rate',
          scheduledAt: eventAt(2, 18),
          country: 'US',
          importance: 'high',
          title: '기준금리 결정',
        },
        {
          id: 'demo-employment',
          scheduledAt: eventAt(4, 12),
          country: 'US',
          importance: 'medium',
          title: '비농업 고용지표',
        },
      ],
    };
  }

  async getAlertSnapshot(): Promise<null> {
    return null;
  }
}
