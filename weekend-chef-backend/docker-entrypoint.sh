#!/bin/sh
set -euo pipefail

if [ -n "${DJANGO_DB_HOST:-}" ]; then
  echo "Waiting for database ${DJANGO_DB_HOST}:${DJANGO_DB_PORT:-5432}..."
  until nc -z "$DJANGO_DB_HOST" "${DJANGO_DB_PORT:-5432}"; do
    sleep 1
  done
fi

if [ "${RUN_MIGRATIONS:-0}" = "1" ]; then
  python manage.py migrate --noinput
fi

if [ "${COLLECT_STATIC:-0}" = "1" ]; then
  python manage.py collectstatic --noinput
fi

exec "$@"
