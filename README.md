# KARADA Tasks

Небольшое приложение: бэкенд на Laravel (PHP) и фронтенд на Vue 3 — задача: регистрация/вход и личный список задач (CRUD).

## Что уже сделано
- Проект Laravel + Vue разложен в `backend/` и `frontend/`.
- Docker Compose конфиг с сервисами `frontend`, `backend`, `mysql`, `redis`.
- Добавлена сущность `Task` (миграция и модель).
- Реализованы API-маршруты `tasks` (защищены `auth:sanctum`).
- Добавлены Policy и сиды: тестовый пользователь `karada@example.com` / `karada` и примеры задач.

## Быстрый старт (только Git и Docker на машине)
Инструкции ниже для Linux (копируйте/вставляйте в терминал).

1) Клонировать репозиторий и перейти в папку:

```bash
git clone <repo-url> && cd <repo-folder>
```

2) Поднять контейнеры Docker:

```bash
docker compose up -d
```

3) Установить PHP-зависимости, создать `.env` и выполнить миграции с сидом (в контейнере `backend`):

```bash
# выполнить одну команду из хоста
docker exec -it backend bash -lc "composer install && cp .env.example .env && php artisan key:generate && php artisan migrate --seed"
```

4) Установить зависимости фронтенда и собрать

```bash
docker exec -it frontend npm install
docker exec -it frontend npm run build
```

5) Открыть приложение:
- Бэкенд доступен на http://localhost (по `docker-compose.yml` порт 80). Фронтенд — на порт 8080 (или собранная версия /static).

## Тестовый пользователь
- email: `karada@example.com`
- password: `karada`

## API (основные точки)
Все `tasks` маршруты защищены `auth:sanctum`. Перед вызовом API получите CSRF cookie и выполните логин (cookie-based).

Маршруты:
- POST /api/tasks — создать задачу
- GET /api/tasks — получить список задач текущего пользователя
- GET /api/tasks/{id} — посмотреть задачу (только если владелец)
- PUT /api/tasks/{id} — обновить задачу (только свой)
- DELETE /api/tasks/{id} — удалить задачу (только свой)

Принимаемые поля при создании/обновлении:
- title (string, 5–120)
- description (text, optional)
- status (string, one of: new, in_progress, done, archived)
- priority (integer, 1–5)
- due_date (date, optional)
- karada_project (string, one of: karada_u, prohuntr, other)

Обратите внимание:
- Поля `karada_test_label` и `importance_score` игнорируются из входящих данных: они устанавливаются на бэкенде.
- `importance_score` = `priority * 20` (пересчитывается при создании/обновлении).
- `karada_test_label` всегда будет `KARADA_FULLSTACK_TEST`.

## Примеры curl (Linux)
1) Получить CSRF cookie:

```bash
curl -c cookiejar -s http://localhost/sanctum/csrf-cookie
```

2) Войти (login) используя тестового пользователя:

```bash
curl -b cookiejar -c cookiejar -X POST http://localhost/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"karada@example.com","password":"karada"}'
```

3) Получить список задач:

```bash
curl -b cookiejar http://localhost/api/tasks
```

4) Создать задачу:

```bash
curl -b cookiejar -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title":"Тестовая задача",
    "description":"Описание",
    "status":"new",
    "priority":3,
    "due_date":"2025-12-31",
    "karada_project":"karada_u"
  }'
```

## Примечания
- В `backend/.env.example` настроены DB-параметры для MySQL (`mysql` сервис из `docker-compose.yml`). При необходимости измените порты/хосты.
- Для разработки фронтенда вы можете запустить `npm run dev` в `frontend` и убедиться, что `SANCTUM_STATEFUL_DOMAINS` включает порт фронтенда (в `docker-compose.yml` уже добавлены `localhost:8080`).
