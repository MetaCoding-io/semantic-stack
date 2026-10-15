#!/usr/bin/env bash
# Store the example LinkedPipes ETL pipeline, run it, wait for it to finish.
#
#   scripts/lp-etl.sh [pipeline.jsonld]        (default: lp-etl/pipelines/semantic-stack.jsonld)
#
# The pipeline is POSTed to /api/v1/pipelines, which keeps the IRI in the file (and overwrites an
# earlier copy), so the run is repeatable and the canvas URL is stable. The execution is then started
# with the frontend's execute endpoint and polled until it is finished or failed; on failure the tail
# of the execution log is printed. The last line of output is LP_ETL_EXECUTION=<execution IRI>, for
# scripts that want to open the execution in the browser (screenshots/take.mjs does).
# Env: LP_ETL_URL (default http://localhost:$LP_ETL_PORT), RETRIES/SLEEP for the readiness wait,
#      LP_ETL_TIMEOUT seconds for the execution (default 300).
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
# shellcheck source=/dev/null
[ -f .env ] && set -a && . ./.env && set +a

FILE="${1:-lp-etl/pipelines/semantic-stack.jsonld}"
LP="${LP_ETL_URL:-http://localhost:${LP_ETL_PORT:-9080}}"
RETRIES="${RETRIES:-40}"; SLEEP="${SLEEP:-5}"; TIMEOUT="${LP_ETL_TIMEOUT:-300}"

PIPELINE="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))[0]["@id"])' "$FILE")" || exit 1
ENC="$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "$PIPELINE")"
OPTIONS="$(mktemp --suffix=.jsonld)"; trap 'rm -f "$OPTIONS"' EXIT
echo '{"@id": "http://localhost/options", "@type": "http://linkedpipes.com/ontology/UpdateOptions"}' > "$OPTIONS"

# 1. store (the frontend proxies to the storage container, which is the last one to come up)
echo "Pipeline: $PIPELINE"
for ((i=1; i<=RETRIES; i++)); do
  code="$(curl -sS -o /dev/null -w '%{http_code}' -H 'Accept: application/ld+json' \
          -F "pipeline=@$FILE;type=application/ld+json" -F "options=@$OPTIONS;type=application/ld+json" \
          "$LP/api/v1/pipelines" 2>/dev/null)"
  [[ "$code" =~ ^2 ]] && break
  [ "$i" -eq "$RETRIES" ] && { echo "storing the pipeline failed (last status $code)" >&2; exit 1; }
  sleep "$SLEEP"
done
echo "Stored:   $LP/#/pipelines/edit/canvas?pipeline=$ENC"

# 2. execute
# The frontend pipes the monitor's answer through; take the execution IRI from it whatever the shape
# ({"iri": ...}, JSON-LD with "@id", ...), and fall back to the newest execution of this pipeline.
RESPONSE="$(curl -sS -X POST -H 'Accept: application/json' "$LP/api/v1/executions?local-iri=$ENC")"
EXECUTION="$(printf '%s' "$RESPONSE" | grep -oE 'https?://[^"<> ]+/resources/executions/[^"<> ]+' | head -1)"
if [ -z "$EXECUTION" ]; then
  sleep 2
  EXECUTION="$(curl -sf -H 'Accept: application/ld+json' "$LP/api/v1/executions-list" | python3 -c '
import json,sys
docs=json.load(sys.stdin); docs=docs if isinstance(docs,list) else [docs]
nodes=[n for d in docs for n in (d.get("@graph",[d]) if isinstance(d,dict) else [])]
mine=[n["@id"] for n in nodes if any(p.get("@id")==sys.argv[1] for p in n.get("http://etl.linkedpipes.com/ontology/pipeline",[]))]
print(sorted(mine)[-1] if mine else "")' "$PIPELINE" 2>/dev/null)"
fi
[ -n "$EXECUTION" ] || { echo "starting the execution failed: $RESPONSE" >&2; exit 1; }
EXEC_ENC="$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=""))' "$EXECUTION")"
echo "Started:  $EXECUTION"

# 3. wait
deadline=$((SECONDS + TIMEOUT)); status=""
while [ $SECONDS -lt $deadline ]; do
  status="$(curl -sf "$LP/api/v1/executions-overview?iri=$EXEC_ENC" | python3 -c '
import json,sys
try: print(json.load(sys.stdin)["status"]["@id"].rsplit("/", 1)[-1])
except Exception: print("")' 2>/dev/null)"
  case "$status" in finished|failed|cancelled|dangling) break ;; esac
  sleep 3
done
echo "Status:   ${status:-unknown} ($LP/#/pipelines/edit/canvas?pipeline=$ENC&execution=$EXEC_ENC)"
if [ "$status" != "finished" ]; then
  echo "--- execution log (tail) ---" >&2
  curl -sf "$LP/api/v1/executions-logs-tail?iri=$EXEC_ENC&n=80" >&2 || true
  exit 1
fi
echo "LP_ETL_EXECUTION=$EXECUTION"
