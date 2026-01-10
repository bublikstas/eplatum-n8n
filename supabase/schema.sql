-- Eplatum Tracker MVP Schema for Supabase
-- Run this in Supabase SQL Editor

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tg_user_id bigint UNIQUE NOT NULL,
    tg_chat_id bigint NOT NULL,
    timezone text DEFAULT 'Europe/Warsaw',
    nudge_level text DEFAULT 'medium' CHECK (nudge_level IN ('low', 'medium', 'high')),
    snoozed_until timestamptz,
    current_step int DEFAULT 1,
    profile jsonb DEFAULT '{}'::jsonb,
    last_seen timestamptz DEFAULT now(),
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tg_user_id bigint NOT NULL,
    role text CHECK (role IN ('user', 'bot')),
    text text,
    created_at timestamptz DEFAULT now()
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tg_user_id bigint NOT NULL,
    status text DEFAULT 'open' CHECK (status IN ('open', 'done', 'cancelled')),
    title text NOT NULL,
    details text,
    due_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Reminders table
CREATE TABLE IF NOT EXISTS reminders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tg_user_id bigint NOT NULL,
    kind text DEFAULT 'nudge',
    next_at timestamptz NOT NULL,
    last_sent_at timestamptz,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_tg_user_id ON users(tg_user_id);
CREATE INDEX IF NOT EXISTS idx_messages_tg_user_id ON messages(tg_user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_tg_user_id_status ON tasks(tg_user_id, status);
CREATE INDEX IF NOT EXISTS idx_reminders_next_at ON reminders(next_at);
CREATE INDEX IF NOT EXISTS idx_reminders_tg_user_id ON reminders(tg_user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reminders_updated_at BEFORE UPDATE ON reminders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
