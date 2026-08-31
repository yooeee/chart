import { BadRequestException } from '@nestjs/common';

import { createDefaultWorkspace, UserProfile } from '../../domain/workspace.models';
import { WorkspaceRepository } from '../../infrastructure/storage/workspace.repository';
import { AlertsService } from './alerts.service';

const profile: UserProfile = {
  id: 'test-user',
  email: 'test@pulse.local',
  displayName: 'Tester',
};

describe('AlertsService', () => {
  const workspace = createDefaultWorkspace(profile);
  const repository: WorkspaceRepository = {
    listWorkspaces: jest.fn(),
    upsertUser: jest.fn(),
    getWorkspace: jest.fn(),
    getWatchlist: jest.fn(),
    saveWatchlistItem: jest.fn(),
    removeWatchlistItem: jest.fn(),
    getPreferences: jest.fn(),
    savePreferences: jest.fn(),
    getAlerts: jest.fn(async () => workspace.alerts),
    saveAlert: jest.fn(async (_userId, alert) => [alert]),
    removeAlert: jest.fn(),
    getNotifications: jest.fn(),
    saveNotification: jest.fn(),
    markNotificationRead: jest.fn(),
  };
  const service = new AlertsService(repository);

  it('creates a price alert with a generated id', async () => {
    const alerts = await service.create(profile.id, {
      name: '목표가',
      symbol: 'BINANCE:BTCUSDT',
      type: 'priceAbove',
      targetPrice: 100000,
    });

    expect(alerts).toHaveLength(1);
    expect(alerts[0].id).toBeTruthy();
    expect(alerts[0].enabled).toBe(true);
  });

  it('rejects a price alert without a target price', async () => {
    await expect(
      service.create(profile.id, {
        name: '잘못된 규칙',
        symbol: 'BINANCE:BTCUSDT',
        type: 'priceAbove',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
