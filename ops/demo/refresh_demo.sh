#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/../weekend-chef-backend"

cd "$BACKEND_DIR"

python manage.py reset_demo_data
python manage.py seed_demo_data
