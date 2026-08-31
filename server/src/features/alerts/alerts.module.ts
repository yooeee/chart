import { Module } from '@nestjs/common';

import { AuthModule } from '../auth/auth.module';
import { MarketModule } from '../market/market.module';
import { AlertEvaluationService } from './alert-evaluation.service';
import { AlertsController } from './alerts.controller';
import { AlertsService } from './alerts.service';

@Module({
  imports: [AuthModule, MarketModule],
  controllers: [AlertsController],
  providers: [AlertsService, AlertEvaluationService],
})
export class AlertsModule {}
