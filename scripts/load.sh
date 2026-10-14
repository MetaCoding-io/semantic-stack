#!/usr/bin/env bash
# Load the sample dataset into the stores that accept writes over HTTP.
#   Fuseki   -> named graph via the Graph Store Protocol (the dataset uses unionDefaultGraph,
#               so data in a *named* graph is what default-graph queries see)
#   Oxigraph -> same, only when it is running (compose.oxigraph.yml)
# QLever is read-only at runtime: index files with `make qlever-index` instead.
#
# Usage: scripts/load.sh [file.ttl ...]      (default: data/sample/*.ttl)
set -euo pipefail
cd "$(dirname "$0")/.." || exit 1
# shellcheck source=/dev/null
if [ -f .env ]; then set -a; . ./.env; set +a; fi

FUSEKI_URL="${FUSEKI_URL:-http://localhost:${FUSEKI_PORT:-3030}}"
FUSEKI_ADMIN_PASSWORD="${FUSEKI_ADMIN_PASSWORD:-admin}"
OXIGRAPH_URL="${OXIGRAPH_URL:-http://localhost:${OXIGRAPH_PORT:-7878}}"
GRAPH="${GRAPH:-http://localhost:${TRIFID_PORT:-8084}/graph/semantic-stack}"

FILES=("$@")
if [ ${#FILES[@]} -eq 0 ]; then FILES=(data/sample/*.ttl); fi

urlencode() { local s="$1"; s="${s//:/%3A}"; s="${s//\//%2F}"; s="${s//#/%23}"; printf '%s' "$s"; }
G="$(urlencode "$GRAPH")"

count() { # count <sparql endpoint>
  curl -sf -H 'Accept: application/sparql-results+json' \
    --data-urlencode "query=SELECT (COUNT(*) AS ?n) WHERE { GRAPH <$GRAPH> { ?s ?p ?o } }" "$1" \
    | grep -oE '"value" *: *"[0-9]+"' | grep -oE '[0-9]+' || echo "?"
}

echo "Graph: $GRAPH"

if curl -sf -o /dev/null "$FUSEKI_URL/ds/sparql?query=ASK%7B%7D"; then
  for f in "${FILES[@]}"; do
    curl -sfS -u "admin:$FUSEKI_ADMIN_PASSWORD" -X POST -H 'Content-Type: text/turtle' \
      --data-binary "@$f" "$FUSEKI_URL/ds/data?graph=$G" > /dev/null
    echo "Fuseki   <- $f"
  done
  echo "Fuseki   triples in graph: $(count "$FUSEKI_URL/ds/sparql")"
else
  echo "Fuseki   not reachable at $FUSEKI_URL, skipped" >&2
fi

if curl -sf -o /dev/null "$OXIGRAPH_URL/query?query=ASK%7B%7D"; then
  for f in "${FILES[@]}"; do
    curl -sfS -X POST -H 'Content-Type: text/turtle' --data-binary "@$f" "$OXIGRAPH_URL/store?graph=$G" > /dev/null
    echo "Oxigraph <- $f"
  done
  echo "Oxigraph triples in graph: $(count "$OXIGRAPH_URL/query")"
else
  echo "Oxigraph not running, skipped (start it with compose.oxigraph.yml)"
fi
