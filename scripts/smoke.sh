#!/usr/bin/env bash
# Smoke test: every service answers on its host port. Used by CI and `make smoke`.
#
# Usage: scripts/smoke.sh [check ...]
#   default checks: landing qlever qlever-ui fuseki rdf4j openrefine webvowl trifid blueprint comunica
#   extra checks:   oxigraph ontop fuseki-data (sample data loaded) graphdb
# Env: RETRIES (default 30), SLEEP seconds between retries (default 5), plus the *_PORT variables from .env.
set -uo pipefail
cd "$(dirname "$0")/.."
if [ -f .env ]; then set -a; . ./.env; set +a; fi

RETRIES="${RETRIES:-30}"
SLEEP="${SLEEP:-5}"
H="http://localhost"
SELECT1="SELECT%20%2A%20WHERE%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20LIMIT%201"

pass=0; fail=0; failed=()
ok()   { printf '  \033[32mok\033[0m    %-12s %s\n' "$1" "$2"; pass=$((pass+1)); }
bad()  { printf '  \033[31mFAIL\033[0m  %-12s %s\n' "$1" "$2"; fail=$((fail+1)); failed+=("$1"); }

# http NAME URL [expected substring]  - retries until 2xx (after redirects) and body contains substring
http() {
  local name="$1" url="$2" want="${3:-}" i body code
  for ((i=1; i<=RETRIES; i++)); do
    body="$(curl -sS -L --max-time 15 -H 'Accept: application/sparql-results+json, text/html;q=0.9, */*;q=0.8' -w '\n%{http_code}' "$url" 2>/dev/null)" || body=$'\n000'
    code="${body##*$'\n'}"
    if [[ "$code" =~ ^2 ]] && { [ -z "$want" ] || grep -q -- "$want" <<<"$body"; }; then ok "$name" "$url"; return 0; fi
    sleep "$SLEEP"
  done
  bad "$name" "$url (last status $code)"; return 1
}

sparql() { http "$1" "$2?query=$SELECT1" '"head"'; }   # any SPARQL engine returns a JSON head
ask()    { http "$1" "$2?query=$(printf '%s' "$3" | sed 's/ /%20/g; s/#/%23/g; s/{/%7B/g; s/}/%7D/g; s/</%3C/g; s/>/%3E/g; s/?/%3F/g; s/:/%3A/g; s/\//%2F/g')" 'true'; }

checks=("$@")
[ ${#checks[@]} -eq 0 ] && checks=(landing qlever qlever-ui fuseki rdf4j openrefine webvowl trifid blueprint comunica)

echo "Smoke test (retries=$RETRIES, sleep=${SLEEP}s)"
for c in "${checks[@]}"; do
  case "$c" in
    landing)     http   landing     "$H:${LANDING_PORT:-8080}/" "semantic-stack" ;;
    qlever)      sparql qlever      "$H:${QLEVER_PORT:-7001}/" ;;
    qlever-ui)   http   qlever-ui   "$H:${QLEVER_UI_PORT:-7000}/" ;;
    fuseki)      sparql fuseki      "$H:${FUSEKI_PORT:-3030}/ds/sparql" ;;
    fuseki-data) ask    fuseki-data "$H:${FUSEKI_PORT:-3030}/ds/sparql" "ASK { ?s a <http://localhost:${TRIFID_PORT:-8084}/vocab/Service> }" ;;
    oxigraph)    sparql oxigraph    "$H:${OXIGRAPH_PORT:-7878}/query" ;;
    oxigraph-data) ask  oxigraph-data "$H:${OXIGRAPH_PORT:-7878}/query" "ASK { ?s a <http://localhost:${TRIFID_PORT:-8084}/vocab/Service> }" ;;
    rdf4j)       http   rdf4j       "$H:${RDF4J_PORT:-8082}/rdf4j-workbench/" ;;
    openrefine)  http   openrefine  "$H:${OPENREFINE_PORT:-3333}/" ;;
    webvowl)     http   webvowl     "$H:${WEBVOWL_PORT:-8083}/serverTimeStamp" ;;
    trifid)      http   trifid      "$H:${TRIFID_PORT:-8084}/sparql/" ;;
    trifid-query) sparql trifid-query "$H:${TRIFID_PORT:-8084}/query" ;;
    blueprint)   http   blueprint   "$H:${BLUEPRINT_PORT:-8085}/" ;;
    comunica)    sparql comunica    "$H:${COMUNICA_PORT:-8087}/sparql" ;;
    ontop)       sparql ontop       "$H:${ONTOP_PORT:-8089}/sparql" ;;
    ontop-data)  ask    ontop-data  "$H:${ONTOP_PORT:-8089}/sparql" "ASK { ?s a <http://localhost:${TRIFID_PORT:-8084}/vocab/Service> }" ;;
    graphdb)     http   graphdb     "$H:${GRAPHDB_PORT:-7200}/rest/repositories" ;;
    *) bad "$c" "unknown check" ;;
  esac
done

echo
echo "$pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then echo "Failed: ${failed[*]}"; exit 1; fi
