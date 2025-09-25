# Weekend Chef Operations Guide

This guide explains how to run the Weekend Chef stack with Docker for local development, demos, or staging.
It assumes Docker Engine v24+ and Docker Compose v2.

## 1. Prepare environment secrets

1. Copy the example environment file and edit values for your deployment:
   ```bash
   cp env.sample .env
   ```
2. Set production-appropriate values for `DJANGO_SECRET_KEY`, database credentials, email providers, and third-party API keys.
3. For cloud environments, store secrets in your platform's secret manager and inject them as environment variables instead of committing `.env`.

## 2. Build and start the stack

Run the full platform (Postgres, Redis, Django API, Channels worker, Celery worker/beat, admin console) with:

```bash
docker compose up --build
```

The backend will run migrations and collect static assets automatically on start. Once containers are healthy:

- API & Channels: http://localhost:8000
- Admin console: http://localhost:4173

Stop services with `Ctrl+C` or by running `docker compose down`.

## 3. Database migrations

Migrations are executed when the backend container starts with `RUN_MIGRATIONS=1`. For manual control:

```bash
docker compose run --rm backend python manage.py migrate
```

To generate new migrations:

```bash
docker compose run --rm backend python manage.py makemigrations <app_name>
```

## 4. Collecting static files

Static assets are collected to the shared `staticfiles` volume during container start (when `COLLECT_STATIC=1`).
If you need to re-run manually:

```bash
docker compose run --rm backend python manage.py collectstatic --noinput
```

## 5. Scaling background workers

Celery workers can be scaled horizontally based on load:

```bash
docker compose up -d --scale celery_worker=3
```

Use `docker compose logs celery_worker` to monitor worker activity.

## 6. Health checks & monitoring

- Postgres and Redis include built-in health checks in `docker-compose.yml`.
- Add Sentry DSNs or other monitoring credentials to `.env` and redeploy to instrument error tracking.

## 7. Staging & production tips

- Override exposed ports or domain names by editing `docker-compose.yml` or using an override file.
- Configure HTTPS termination via a reverse proxy (e.g., Traefik, Nginx) in front of the `backend` and `admin` services.
- Back up the `postgres-data`, `staticfiles`, and `mediafiles` volumes for disaster recovery.
- For managed databases or caches, disable the bundled Postgres/Redis services and point `DJANGO_DB_HOST` or `CELERY_BROKER_URL` at the managed endpoints.

## 8. Troubleshooting

- Ensure `.env` exists before running `docker compose` or environment variables will fall back to defaults.
- If migrations fail because Postgres is still starting, rerun `docker compose up` after verifying the database logs.
- Use `docker compose logs -f <service>` for real-time diagnostics.

## 9. Automated QA smoke tests

- End-to-end order lifecycle checks live in `ops/e2e` and rely on the Django QA smoke endpoint enabled via `QA_SMOKE_ENABLED`.
- Start the backend locally (`docker compose up backend`) and run `npm --prefix ops/e2e run test:e2e` to execute the Cypress suite.
- Configure `BACKEND_BASE_URL` to point to a staging deployment when running the tests against remote environments.

This document, together with `AGENTS.md`, forms the operational playbook for delivering Weekend Chef in investor demos and production pilots.
