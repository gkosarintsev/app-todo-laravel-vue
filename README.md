# KARADA Tasks

Небольшое приложение: бэкенд на Laravel (PHP) и фронтенд на Vue 3 — задача: регистрация/вход и личный список задач (CRUD).

- Проект Laravel + Vue разложен в `backend/` и `frontend/`.
- Docker Compose конфиг с сервисами `frontend`, `backend`, `mysql`, `redis`.
- Добавлена сущность `Task` (миграция и модель).
- Реализованы API-маршруты `tasks` (защищены `auth:sanctum`).
- Добавлены Policy и сиды: тестовый пользователь `karada@example.com` / `karada` и примеры задач.

## Быстрый старт
На компьютере должны быть установлен Git и Docker

Если запускаете на Windows, запускайте команды из Git Bash

Инструкции ниже для Linux (копируйте/вставляйте в терминал).

1) Клонировать репозиторий и перейти в папку:

```bash
git clone https://github.com/gkosarintsev/app-todo-laravel-vue.git && cd app-todo-laravel-vue
```

2) Поднять контейнеры Docker:

```bash
docker compose up -d
```

3) Установить PHP-зависимости, создать `.env` и выполнить миграции с сидом (в контейнере `backend`):

```bash

docker exec -it backend bash -lc "composer install && cp .env.example .env && php artisan key:generate && php artisan migrate --seed"
```

4) Установить зависимости фронтенда и собрать

```bash
docker exec -it frontend npm install
docker exec -it frontend npm run build
```

5) Открыть приложение:
- Бэкенд доступен на http://localhost
- Фронтенд — http://localhost:8080

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

Обратите внимание:
- Поля `karada_test_label` и `importance_score` игнорируются из входящих данных: они устанавливаются на бэкенде.
- `importance_score` = `priority * 20` (пересчитывается при создании/обновлении).
- `karada_test_label` всегда будет `KARADA_FULLSTACK_TEST`.
