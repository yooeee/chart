import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AlertsModule } from './features/alerts/alerts.module';
import { AuthModule } from './features/auth/auth.module';
import { HealthModule } from './features/health/health.module';
import { MarketModule } from './features/market/market.module';
import { NotificationsModule } from './features/notifications/notifications.module';
import { PreferencesModule } from './features/preferences/preferences.module';
import { WatchlistModule } from './features/watchlist/watchlist.module';
import { StorageModule } from './infrastructure/storage/storage.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    StorageModule,
    AuthModule,
    WatchlistModule,
    PreferencesModule,
    AlertsModule,
    NotificationsModule,
    MarketModule,
    HealthModule,
  ],
})
export class AppModule {}
