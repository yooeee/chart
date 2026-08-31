import { BadRequestException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';

import { AlertRule, UserNotification } from '../../domain/workspace.models';
import { WORKSPACE_REPOSITORY } from '../../infrastructure/storage/workspace.repository';
import type { WorkspaceRepository } from '../../infrastructure/storage/workspace.repository';
import { CreateAlertDto } from './dto/create-alert.dto';
import { UpdateAlertDto } from './dto/update-alert.dto';

@Injectable()
export class AlertsService {
  constructor(
    @Inject(WORKSPACE_REPOSITORY)
    private readonly repository: WorkspaceRepository,
  ) {}

  getAll(userId: string): Promise<AlertRule[]> {
    return this.repository.getAlerts(userId);
  }

  async create(userId: string, dto: CreateAlertDto): Promise<AlertRule[]> {
    this.validateRule(dto);
    const now = new Date().toISOString();
    return this.repository.saveAlert(userId, {
      id: randomUUID(),
      name: dto.name,
      symbol: dto.symbol,
      type: dto.type,
      targetPrice: dto.targetPrice,
      indicatorId: dto.indicatorId,
      enabled: dto.enabled ?? true,
      createdAt: now,
      updatedAt: now,
    });
  }

  async update(userId: string, alertId: string, dto: UpdateAlertDto): Promise<AlertRule[]> {
    const alerts = await this.repository.getAlerts(userId);
    const existing = alerts.find((alert) => alert.id === alertId);
    if (!existing) throw new NotFoundException('알림 규칙을 찾을 수 없습니다.');
    const updated: AlertRule = { ...existing, ...dto, updatedAt: new Date().toISOString() };
    this.validateRule(updated);
    return this.repository.saveAlert(userId, updated);
  }

  remove(userId: string, alertId: string): Promise<AlertRule[]> {
    return this.repository.removeAlert(userId, alertId);
  }

  async test(userId: string, alertId: string): Promise<UserNotification> {
    const alerts = await this.repository.getAlerts(userId);
    const alert = alerts.find((item) => item.id === alertId);
    if (!alert) throw new NotFoundException('알림 규칙을 찾을 수 없습니다.');
    const notification: UserNotification = {
      id: randomUUID(),
      title: '알림 테스트 성공',
      message: `${alert.name} 규칙이 정상적으로 연결되어 있습니다.`,
      read: false,
      createdAt: new Date().toISOString(),
    };
    await this.repository.saveNotification(userId, notification);
    return notification;
  }

  private validateRule(rule: Pick<AlertRule, 'type' | 'targetPrice' | 'indicatorId'>): void {
    if (rule.type.startsWith('price') && rule.targetPrice == null) {
      throw new BadRequestException('가격 알림에는 targetPrice가 필요합니다.');
    }
    if (rule.type.startsWith('indicator') && !rule.indicatorId) {
      throw new BadRequestException('지표 알림에는 indicatorId가 필요합니다.');
    }
  }
}
