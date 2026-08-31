export type ChartTheme = 'light' | 'dark';
export type ChartInterval = '1' | '5' | '15' | '30' | '60' | '240' | 'D' | 'W' | 'M';
export type AlertType = 'priceAbove' | 'priceBelow' | 'indicatorBuy' | 'indicatorSell';

export interface UserProfile {
  id: string;
  email: string;
  displayName: string;
  photoUrl?: string;
}

export interface WatchlistItem {
  symbol: string;
  ticker: string;
  displayName: string;
  exchange: string;
  createdAt: string;
}

export interface ChartPreferences {
  symbol: string;
  interval: ChartInterval;
  theme: ChartTheme;
  activeIndicators: string[];
  updatedAt: string;
}

export interface AlertRule {
  id: string;
  name: string;
  symbol: string;
  type: AlertType;
  targetPrice?: number;
  indicatorId?: string;
  enabled: boolean;
  lastTriggeredAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface UserNotification {
  id: string;
  title: string;
  message: string;
  read: boolean;
  createdAt: string;
}

export interface UserWorkspace {
  profile: UserProfile;
  watchlist: WatchlistItem[];
  preferences: ChartPreferences;
  alerts: AlertRule[];
  notifications: UserNotification[];
}

export function createDefaultWorkspace(profile: UserProfile): UserWorkspace {
  const now = new Date().toISOString();
  return {
    profile,
    watchlist: [
      {
        symbol: 'BINANCE:BTCUSDT',
        ticker: 'BTCUSD',
        displayName: 'Bitcoin',
        exchange: 'BINANCE',
        createdAt: now,
      },
      {
        symbol: 'KRX:005930',
        ticker: 'SAMSUNG',
        displayName: '삼성전자',
        exchange: 'KRX',
        createdAt: now,
      },
    ],
    preferences: {
      symbol: 'BINANCE:BTCUSDT',
      interval: 'D',
      theme: 'light',
      activeIndicators: [],
      updatedAt: now,
    },
    alerts: [],
    notifications: [],
  };
}
