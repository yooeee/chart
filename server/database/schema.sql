CREATE TABLE pulse_user (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  photo_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE watchlist_item (
  user_id TEXT NOT NULL REFERENCES pulse_user(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL,
  ticker TEXT NOT NULL,
  display_name TEXT NOT NULL,
  exchange TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, symbol)
);

CREATE TABLE chart_preferences (
  user_id TEXT PRIMARY KEY REFERENCES pulse_user(id) ON DELETE CASCADE,
  symbol TEXT NOT NULL,
  interval_code TEXT NOT NULL,
  theme TEXT NOT NULL CHECK (theme IN ('light', 'dark')),
  active_indicators JSONB NOT NULL DEFAULT '[]'::JSONB,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE alert_rule (
  id UUID PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES pulse_user(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  symbol TEXT NOT NULL,
  type TEXT NOT NULL CHECK (
    type IN ('priceAbove', 'priceBelow', 'indicatorBuy', 'indicatorSell')
  ),
  target_price NUMERIC,
  indicator_id TEXT,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  last_triggered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX alert_rule_enabled_symbol_index
  ON alert_rule (enabled, symbol)
  WHERE enabled = TRUE;

CREATE TABLE pulse_notification (
  id UUID PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES pulse_user(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX pulse_notification_user_created_index
  ON pulse_notification (user_id, created_at DESC);
