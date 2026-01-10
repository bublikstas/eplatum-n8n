# eplatum-n8n

## Render Deployment

This repository is configured to deploy on Render as a **Docker service** using the official n8n Docker image (`n8nio/n8n:2.2.4`). The Dockerfile handles workflow imports and n8n startup automatically.

**Note:** Node.js build commands (`npm install`, `npm start`) are no longer used. Render should be configured as a Docker service, not a Node service.

## Eplatum Tracker MVP

Telegram-бот для профориентации и предпринимательства с онбордингом, напоминаниями и "следующими шагами".

### Настройка (один раз)

#### 1. Создать Telegram Bot Credentials в n8n

1. Откройте n8n UI (после деплоя на Render)
2. Перейдите в **Credentials** → **New** → **Telegram**
3. Введите Bot Token от @BotFather
4. Сохраните credentials (запомните ID или название, например "Telegram Bot")
5. Экспортируйте workflow с Telegram Trigger:
   - Создайте простой workflow с одной нодой "Telegram Trigger"
   - Примените созданные credentials
   - Сохраните workflow
   - Экспортируйте его в JSON
   - Скопируйте файл в `workflows/_seed-telegram.json`
   - **ВАЖНО:** Замените `REPLACE_WITH_TELEGRAM_CREDENTIALS_ID` в обоих workflow файлах на реальный ID credentials

#### 2. Настроить Supabase

1. Создайте проект в Supabase
2. Откройте **SQL Editor**
3. Скопируйте содержимое `supabase/schema.sql` и выполните
4. Создайте Postgres credentials в n8n:
   - **Credentials** → **New** → **Postgres**
   - Используйте Connection String из Supabase (Settings → Database → Connection String)
   - Сохраните credentials (запомните ID)
   - **ВАЖНО:** Замените `REPLACE_WITH_SUPABASE_CREDENTIALS_ID` во всех workflow файлах на реальный ID

#### 3. Environment Variables (опционально)

В Render добавьте env vars (если используете):

- `OPENAI_API_KEY` или `ANTHROPIC_API_KEY` — для LLM (зеркалка/следующие шаги)
- `TG_ADMIN_ID` — ваш Telegram user ID (опционально)
- `DEFAULT_TIMEZONE=Europe/Warsaw` — дефолтная таймзона

Если LLM credentials нет — бот будет использовать fallback (простые ответы).

### Как проверить

1. **Деплой:**
   - Сделайте `git push` → Render автоматически соберет и задеплоит
   - `entrypoint.sh` импортирует workflows из `/home/node/workflows/`

2. **Активация workflows:**
   - Откройте n8n UI
   - Активируйте оба workflow:
     - `Eplatum Tracker Chat` (Telegram Trigger)
     - `Eplatum Tracker Reminders` (Cron)

3. **Тестирование:**
   - Отправьте `/start` боту в Telegram
   - Ответьте на 2-3 вопроса онбординга
   - Проверьте `/status`
   - Измените настройку: `/nudge high`
   - Проверьте напоминания (через 30 минут или временно установите `nudge_level=high` для быстрого теста)

4. **Проверка данных:**
   - Откройте Supabase → Table Editor
   - Проверьте таблицы: `users`, `messages`, `tasks`, `reminders`

### Команды бота

- `/start` — начать/продолжить онбординг
- `/status` — текущий статус (шаг, прогресс, настройки)
- `/nudge low|medium|high` — изменить частоту напоминаний
- `/snooze 24h|72h` — приостановить напоминания
- `/reset` — сбросить (требует подтверждения "RESET")
- `/help` — справка

### Структура онбординга (7 шагов)

1. Что хочешь изменить? (работа/бизнес/жизнь/деньги/смысл)
2. Ограничения (время, деньги, язык, город)
3. Что нравится (3 активности/темы)
4. Что получается (3 навыка/опыта)
5. Формат (найм/фриланс/продукт/контент/консалтинг/бизнес)
6. Риск/темп (безопасно/быстро/агрессивно)
7. Критерий успеха на 30 дней

После шага 7: генерируется "следующий шаг на 15 минут" (LLM или шаблон).

### Напоминания

- **low:** раз в 48 часов
- **medium:** раз в 24 часа (по умолчанию)
- **high:** раз в 8 часов (не ночью, 22:00-08:00 пропускается)

Напоминания работают даже если онбординг не завершен.