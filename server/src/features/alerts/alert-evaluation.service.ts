import { Inject, Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomUUID } from 'node:crypto';

import { AlertRule, UserWorkspace } from '../../domain/workspace.models';
import { WORKSPACE_REPOSITORY } from '../../infrastructure/storage/workspace.repository';
import type { WorkspaceRepository } from '../../infrastructure/storage/workspace.repository';
import { MARKET_DATA_PROVIDER } from '../market/market-data.provider';
import type { AlertMarketSnapshot, MarketDataProvider } from '../market/market-data.provider';

@Injectable()
export class AlertEvaluationService implements OnModuleInit, OnModuleDestroy {
  private timer?: ReturnType<typeof setInterval>;
  private evaluating = false;
  private readonly pollIntervalMilliseconds: number;
  private readonly cooldownMilliseconds: number;

  constructor(
    configService: ConfigService,
    @Inject(WORKSPACE_REPOSITORY)
    private readonly repository: WorkspaceRepository,
    @Inject(MARKET_DATA_PROVIDER)
    private readonly marketDataProvider: MarketDataProvider,
  ) {
    this.pollIntervalMilliseconds = Number(
      configService.get<string>('ALERT_POLL_INTERVAL_MS', '60000'),
    );
    this.cooldownMilliseconds = Number(configService.get<string>('ALERT_COOLDOWN_MS', '3600000'));
  }

  onModuleInit(): void {
    if (!this.marketDataProvider.supportsAlertEvaluation) return;
    this.timer = setInterval(() => void this.evaluateAll(), this.pollIntervalMilliseconds);
  }

  onModuleDestroy(): void {
    if (this.timer) clearInterval(this.timer);
  }

  async evaluateAll(): Promise<void> {
    if (this.evaluating || !this.marketDataProvider.supportsAlertEvaluation) return;
    this.evaluating = true;
    try {
      const workspaces = await this.repository.listWorkspaces();
      for (const workspace of workspaces) await this.evaluateWorkspace(workspace);
    } finally {
      this.evaluating = false;
    }
  }

  private async evaluateWorkspace(workspace: UserWorkspace): Promise<void> {
    for (const alert of workspace.alerts.filter((item) => item.enabled)) {
      if (this.isCoolingDown(alert)) continue;
      const snapshot = await this.marketDataProvider.getAlertSnapshot(
        alert.symbol,
        alert.indicatorId,
      );
      if (!snapshot || !this.matches(alert, snapshot)) continue;

      const triggeredAt = new Date().toISOString();
      await this.repository.saveAlert(workspace.profile.id, {
        ...alert,
        lastTriggeredAt: triggeredAt,
        updatedAt: triggeredAt,
      });
      await this.repository.saveNotification(workspace.profile.id, {
        id: randomUUID(),
        title: alert.name,
        message: this.triggerMessage(alert, snapshot),
        read: false,
        createdAt: triggeredAt,
      });
    }
  }

  private isCoolingDown(alert: AlertRule): boolean {
    if (!alert.lastTriggeredAt) return false;
    return Date.now() - Date.parse(alert.lastTriggeredAt) < this.cooldownMilliseconds;
  }

  private matches(alert: AlertRule, snapshot: AlertMarketSnapshot): boolean {
    return (
      (alert.type === 'priceAbove' && snapshot.price >= (alert.targetPrice ?? Infinity)) ||
      (alert.type === 'priceBelow' && snapshot.price <= (alert.targetPrice ?? -Infinity)) ||
      (alert.type === 'indicatorBuy' && snapshot.indicatorSignal === 'buy') ||
      (alert.type === 'indicatorSell' && snapshot.indicatorSignal === 'sell')
    );
  }

  private triggerMessage(alert: AlertRule, snapshot: AlertMarketSnapshot): string {
    if (alert.type.startsWith('price')) {
      return `${alert.symbol} 가격이 ${snapshot.price}에 도달했습니다.`;
    }
    return `${alert.symbol}에서 ${alert.indicatorId} ${snapshot.indicatorSignal} 신호가 발생했습니다.`;
  }
}
