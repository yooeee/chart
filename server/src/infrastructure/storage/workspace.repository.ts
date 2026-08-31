import {
  AlertRule,
  ChartPreferences,
  UserNotification,
  UserProfile,
  UserWorkspace,
  WatchlistItem,
} from '../../domain/workspace.models';

export const WORKSPACE_REPOSITORY = Symbol('WORKSPACE_REPOSITORY');

export interface WorkspaceRepository {
  listWorkspaces(): Promise<UserWorkspace[]>;
  upsertUser(profile: UserProfile): Promise<UserWorkspace>;
  getWorkspace(userId: string): Promise<UserWorkspace>;
  getWatchlist(userId: string): Promise<WatchlistItem[]>;
  saveWatchlistItem(userId: string, item: WatchlistItem): Promise<WatchlistItem[]>;
  removeWatchlistItem(userId: string, symbol: string): Promise<WatchlistItem[]>;
  getPreferences(userId: string): Promise<ChartPreferences>;
  savePreferences(userId: string, preferences: ChartPreferences): Promise<ChartPreferences>;
  getAlerts(userId: string): Promise<AlertRule[]>;
  saveAlert(userId: string, alert: AlertRule): Promise<AlertRule[]>;
  removeAlert(userId: string, alertId: string): Promise<AlertRule[]>;
  getNotifications(userId: string): Promise<UserNotification[]>;
  saveNotification(userId: string, notification: UserNotification): Promise<UserNotification[]>;
  markNotificationRead(userId: string, notificationId: string): Promise<UserNotification[]>;
}
