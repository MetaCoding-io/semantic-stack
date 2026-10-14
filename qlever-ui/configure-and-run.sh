#!/usr/bin/env bash
# Entrypoint for the qlever-ui service.
# The image ships a SQLite database with preconfigured backends (Wikidata, Olympics, ...).
# This script points the backend named in QLEVER_UI_BACKEND_SLUG at our QLever server,
# makes it the default, hides the others, then starts the web app. Same steps `qlever ui` runs.
set -euo pipefail
cd /app

SLUG="${QLEVER_UI_BACKEND_SLUG:-olympics}"
URL="${QLEVER_UI_BACKEND_URL:-http://localhost:7001}"
CFG="/tmp/${SLUG}.yaml"

python manage.py config "$SLUG" > "$CFG"
python - "$CFG" "$URL" <<'PY'
import sys, yaml
path, url = sys.argv[1], sys.argv[2]
with open(path) as f:
    cfg = yaml.safe_load(f)
backend = cfg["config"]["backend"]
backend["baseUrl"] = url
backend["isDefault"] = True
backend["sortKey"] = 1
with open(path, "w") as f:
    yaml.safe_dump(cfg, f, sort_keys=False)
PY
python manage.py config "$SLUG" "$CFG" --hide-all-other-backends
echo "QLever UI: backend '$SLUG' -> $URL"

exec gunicorn --bind :7000 --workers 3 --limit-request-line 10000 qlever.wsgi:application
