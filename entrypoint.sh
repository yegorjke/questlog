#!/bin/bash
set -e

HOST="db"
PORT="5432"

ls -a
echo "Waiting for PostgreSQL at $HOST:$PORT to become available..."
/wait-for-it.sh $HOST:$PORT --timeout=60 --strict -- echo "PostgreSQL is available."

echo "Running migrations..."
uv run --no-sync alembic upgrade head
echo "...end."

exec "$@"
