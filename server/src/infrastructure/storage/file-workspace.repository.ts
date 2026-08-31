import { Injectable, NotFoundException, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { mkdir, readFile, rename, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';

import {
  AlertRule,
  ChartPreferences,
  createDefaultWorkspace,
  UserNotification,
  UserProfile,
  UserWorkspace,
  WatchlistItem,
} from '../../domain/workspace.models';
import { WorkspaceRepository } from './workspace.repository';

type WorkspaceDatabase = Record<string, UserWorkspace>;

@Injectable()
export class FileWorkspaceRepository implements WorkspaceRepository, OnModuleInit {
  private readonly dataFile: string;
  private database: WorkspaceDatabase = {};
  private operationQueue: Promise<unknown> = Promise.resolve();

  constructor(configService: ConfigService) {
    this.dataFile = resolve(configService.get<string>('DATA_FILE') ?? './data/workspace.json');
  }

  async onModuleInit(): Promise<void> {
    await mkdir(dirname(this.dataFile), { recursive: true });
    try {
      this.database = JSON.parse(await readFile(this.dataFile, 'utf8')) as WorkspaceDatabase;
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== 'ENOENT') throw error;
      await this.persist();
    }
  }

  async upsertUser(profile: UserProfile): Promise<UserWorkspace> {
    return this.mutate(() => {
      const existing = this.database[profile.id];
      this.database[profile.id] = existing
        ? { ...existing, profile: { ...existing.profile, ...profile } }
        : createDefaultWorkspace(profile);
      return this.database[profile.id];
    });
  }

  async listWorkspaces(): Promise<UserWorkspace[]> {
    return structuredClone(Object.values(this.database));
  }

  async getWorkspace(userId: string): Promise<UserWorkspace> {
    return this.readWorkspace(userId);
  }

  async getWatchlist(userId: string): Promise<WatchlistItem[]> {
    return this.readWorkspace(userId).watchlist;
  }

  async saveWatchlistItem(userId: string, item: WatchlistItem): Promise<WatchlistItem[]> {
    return this.mutate(() => {
      const workspace = this.requireWorkspace(userId);
      const withoutDuplicate = workspace.watchlist.filter((entry) => entry.symbol !== item.symbol);
      workspace.watchlist = [item, ...withoutDuplicate].slice(0, 50);
      return workspace.watchlist;
    });
  }

  async removeWatchlistItem(userId: string, symbol: string): Promise<WatchlistItem[]> {
    return this.mutate(() => {
      const workspace = this.requireWorkspace(userId);
      workspace.watchlist = workspace.watchlist.filter((item) => item.symbol !== symbol);
      return workspace.watchlist;
    });
  }

  async getPreferences(userId: string): Promise<ChartPreferences> {
    return this.readWorkspace(userId).preferences;
  }

  async savePreferences(userId: string, preferences: ChartPreferences): Promise<ChartPreferences> {
    return this.mutate(() => {
      const workspace = this.requireWorkspace(userId);
      workspace.preferences = preferences;
      return workspace.preferences;
    });
  }

  async getAlerts(userId: string): Promise<AlertRule[]> {
    return this.readWorkspace(userId).alerts;
  }

  async saveAlert(userId: string, alert: AlertRule): Promise<AlertRule[]> {
    return this.mutate(() => {
      const workspace = this.requireWorkspace(userId);
      const alertIndex = workspace.alerts.findIndex((item) => item.id === alert.id);
      if (alertIndex >= 0) workspace.alerts[alertIndex] = alert;
      else workspace.alerts.unshift(alert);
      return workspace.alerts;
    });
  }

  async removeAlert(userId: string, alertId: string): Promise<AlertRule[]> {
    return this.mutate(() => {
      const workspace = this.requireWorkspace(userId);
      workspace.alerts = workspace.alerts.filter((alert) => alert.id !== alertId);
      return workspace.alerts;
    });
  }

  async getNotifications(userId: string): Promise<UserNotification[]> {
    return this.readWorkspace(userId).notifications;
  }

  async saveNotification(
    userId: string,
    notification: UserNotification,
  ): Promise<UserNotification[]> {
    return this.mutate(() => {
      const workspace = this.requireWorkspace(userId);
      workspace.notifications = [notification, ...workspace.notifications].slice(0, 100);
      return workspace.notifications;
    });
  }

  async markNotificationRead(userId: string, notificationId: string): Promise<UserNotification[]> {
    return this.mutate(() => {
      const workspace = this.requireWorkspace(userId);
      workspace.notifications = workspace.notifications.map((notification) =>
        notification.id === notificationId ? { ...notification, read: true } : notification,
      );
      return workspace.notifications;
    });
  }

  private readWorkspace(userId: string): UserWorkspace {
    return structuredClone(this.requireWorkspace(userId));
  }

  private requireWorkspace(userId: string): UserWorkspace {
    const workspace = this.database[userId];
    if (!workspace) throw new NotFoundException('사용자 작업공간을 찾을 수 없습니다.');
    return workspace;
  }

  private async mutate<T>(operation: () => T): Promise<T> {
    const queuedOperation = this.operationQueue.then(async () => {
      const result = operation();
      await this.persist();
      return structuredClone(result);
    });
    this.operationQueue = queuedOperation.catch(() => undefined);
    return queuedOperation;
  }

  private async persist(): Promise<void> {
    const temporaryFile = `${this.dataFile}.tmp`;
    await writeFile(temporaryFile, JSON.stringify(this.database, null, 2), 'utf8');
    await rename(temporaryFile, this.dataFile);
  }
}
