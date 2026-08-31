import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { DemoMarketDataProvider } from './demo-market-data.provider';
import { MARKET_DATA_PROVIDER } from './market-data.provider';
import { MarketController } from './market.controller';
import { MarketService } from './market.service';
import { UnconfiguredMarketDataProvider } from './unconfigured-market-data.provider';

@Module({
  controllers: [MarketController],
  providers: [
    MarketService,
    DemoMarketDataProvider,
    UnconfiguredMarketDataProvider,
    {
      provide: MARKET_DATA_PROVIDER,
      inject: [ConfigService, DemoMarketDataProvider, UnconfiguredMarketDataProvider],
      useFactory: (
        configService: ConfigService,
        demoProvider: DemoMarketDataProvider,
        unconfiguredProvider: UnconfiguredMarketDataProvider,
      ) => {
        const configuredMode = configService.get<string>('MARKET_DATA_MODE');
        const defaultMode =
          configService.get<string>('NODE_ENV') === 'production' ? 'disabled' : 'demo';
        return (configuredMode ?? defaultMode) === 'demo' ? demoProvider : unconfiguredProvider;
      },
    },
  ],
  exports: [MARKET_DATA_PROVIDER],
})
export class MarketModule {}
