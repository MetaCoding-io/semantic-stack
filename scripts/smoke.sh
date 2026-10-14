#!/usr/bin/env bash
# Smoke test: every service answers on its host port. Used by CI and `make smoke`.
#
# Usage: scripts/smoke.sh [check ...]
#   default checks: landing fuseki fuseki-data rdf4j openrefine webvowl trifid trifid-query blueprint comunica
#                   sparql-proxy skosmos sparklis sparnatural shacl-play pyshacl sparql-anything
#   profile checks: qlever qlever-ui oxigraph oxigraph-data ontop ontop-data graphdb rdf4j-ui
#                   virtuoso virtuoso-data geosparql geosparql-data geosparql-query solid prez prez-ui
#                   grlc grlc-query graph-explorer pylode pylode-render rpt rpt-query lp-etl
#                   itb-shacl itb-validate prometheus sparql-exporter grafana
#                   sparql-mcp rudof-mcp open-ontologies graphrag graphrag-ui graphrag-mcp qdrant ollama
#   extra checks:   skosmos-data pyshacl-validate (needs python3 on the host)
# Env: RETRIES (default 30), SLEEP seconds between retries (default 5), plus the *_PORT variables from .env.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
# shellcheck source=/dev/null
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
  local name="$1" url="$2" want="${3:-}" i body code jar
  jar="$(mktemp)"   # cookie jar: the RDF4J Workbench keeps its server selection in a cookie
  for ((i=1; i<=RETRIES; i++)); do
    body="$(curl -sS -L --max-time 15 -c "$jar" -b "$jar" -H "Accept: ${ACCEPT:-application/sparql-results+json, text/html;q=0.9, */*;q=0.8}" -w '\n%{http_code}' "$url" 2>/dev/null)" || body=$'\n000'
    code="${body##*$'\n'}"
    if [[ "$code" =~ ^2 ]] && { [ -z "$want" ] || grep -q -- "$want" <<<"$body"; }; then ok "$name" "$url"; rm -f "$jar"; return 0; fi
    sleep "$SLEEP"
  done
  rm -f "$jar"
  bad "$name" "$url (last status $code)"; return 1
}

sparql() { http "$1" "$2?query=$SELECT1" '"head"'; }   # any SPARQL engine returns a JSON head
ask()    { http "$1" "$2?query=$(printf '%s' "$3" | sed 's/ /%20/g; s/#/%23/g; s/{/%7B/g; s/}/%7D/g; s/</%3C/g; s/>/%3E/g; s/?/%3F/g; s/:/%3A/g; s/\//%2F/g')" 'true'; }

checks=("$@")
[ ${#checks[@]} -eq 0 ] && checks=(landing fuseki fuseki-data rdf4j openrefine webvowl trifid trifid-query blueprint comunica sparql-proxy skosmos sparklis sparnatural shacl-play pyshacl sparql-anything)

# post NAME URL CONTENT-TYPE BODY [expected substring]  - one POST, retried like http()
post() {
  local name="$1" url="$2" ctype="$3" data="$4" want="${5:-}" i body code
  for ((i=1; i<=RETRIES; i++)); do
    body="$(curl -sS --max-time 30 -H "Content-Type: $ctype" -H "Accept: ${ACCEPT:-application/json, text/event-stream, text/turtle;q=0.9, */*;q=0.8}" --data-binary "$data" -w '\n%{http_code}' "$url" 2>/dev/null)" || body=$'\n000'
    code="${body##*$'\n'}"
    if [[ "$code" =~ ^2 ]] && { [ -z "$want" ] || grep -q -- "$want" <<<"$body"; }; then ok "$name" "$url"; return 0; fi
    sleep "$SLEEP"
  done
  bad "$name" "$url (last status $code)"; return 1
}

# sse NAME URL [expected substring]  - reads the first bytes of a never-ending event stream
sse() {
  local name="$1" url="$2" want="${3:-}" i body
  for ((i=1; i<=RETRIES; i++)); do
    body="$(curl -sN --max-time 3 -H 'Accept: text/event-stream' "$url" 2>/dev/null | head -c 2000)"
    if [ -n "$body" ] && { [ -z "$want" ] || grep -q -- "$want" <<<"$body"; }; then ok "$name" "$url"; return 0; fi
    sleep "$SLEEP"
  done
  bad "$name" "$url (no event stream)"; return 1
}

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
    rdf4j)       http   rdf4j       "$H:${RDF4J_PORT:-8082}/rdf4j-server/protocol" ;;
    rdf4j-ui)    http   rdf4j-ui    "$H:${RDF4J_PORT:-8082}/rdf4j-workbench/repositories" ;;
    openrefine)  http   openrefine  "$H:${OPENREFINE_PORT:-3333}/" ;;
    webvowl)     http   webvowl     "$H:${WEBVOWL_PORT:-8083}/serverTimeStamp" ;;
    trifid)      http   trifid      "$H:${TRIFID_PORT:-8084}/sparql/" ;;
    trifid-query) sparql trifid-query "$H:${TRIFID_PORT:-8084}/query" ;;
    blueprint)   http   blueprint   "$H:${BLUEPRINT_PORT:-8085}/" ;;
    comunica)    sparql comunica    "$H:${COMUNICA_PORT:-8087}/sparql" ;;
    ontop)       sparql ontop       "$H:${ONTOP_PORT:-8089}/sparql" ;;
    ontop-data)  ask    ontop-data  "$H:${ONTOP_PORT:-8089}/sparql" "ASK { ?s a <http://localhost:${TRIFID_PORT:-8084}/vocab/Service> }" ;;
    graphdb)     http   graphdb     "$H:${GRAPHDB_PORT:-7200}/rest/repositories" ;;
    sparql-proxy) ACCEPT=application/sparql-results+json sparql sparql-proxy "$H:${SPARQL_PROXY_PORT:-8090}/sparql" ;;
    skosmos)     http   skosmos     "$H:${SKOSMOS_PORT:-9090}/" "Skosmos" ;;
    skosmos-data) http  skosmos-data "$H:${SKOSMOS_PORT:-9090}/rest/v1/stack/topConcepts?lang=en" "Storage and querying" ;;
    sparklis)    http   sparklis    "$H:${SPARKLIS_PORT:-8092}/osparklis.html" "Sparklis" ;;
    shacl-play)  http   shacl-play  "$H:${SHACL_PLAY_PORT:-8091}/" "SHACL" ;;
    pyshacl)     http   pyshacl     "$H:${PYSHACL_PORT:-8099}/docs/openapi.json" "validate" ;;
    pyshacl-validate) post pyshacl-validate "$H:${PYSHACL_PORT:-8099}/validate" application/json \
                   "$(python3 -c 'import json,sys; print(json.dumps({"data_graph": open("data/sample/semantic-stack.ttl").read(), "shapes_graph": open("data/sample/shapes.ttl").read()}))')" '"conforms"' ;;
    sparql-anything) sparql sparql-anything "$H:${SPARQL_ANYTHING_PORT:-8093}/sparql.anything" ;;
    sparnatural) http   sparnatural "$H:${SPARNATURAL_PORT:-8094}/" "spar-natural" ;;
    virtuoso)    sparql virtuoso    "$H:${VIRTUOSO_PORT:-8890}/sparql" ;;
    virtuoso-data) ask  virtuoso-data "$H:${VIRTUOSO_PORT:-8890}/sparql" "ASK { ?s a <http://localhost:${TRIFID_PORT:-8084}/vocab/Service> }" ;;
    geosparql)   sparql geosparql   "$H:${FUSEKI_GEOSPARQL_PORT:-3031}/ds/sparql" ;;
    geosparql-data) ask geosparql-data "$H:${FUSEKI_GEOSPARQL_PORT:-3031}/ds/sparql" "ASK { ?s a <http://localhost:${TRIFID_PORT:-8084}/vocab/Service> }" ;;
    geosparql-query) http geosparql-query "$H:${FUSEKI_GEOSPARQL_PORT:-3031}/ds/sparql?query=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(open("data/queries/40-geosparql-nearby.rq").read()))')" "Zazuko" ;;
    solid)       http   solid       "$H:${SOLID_PORT:-8100}/" "Community Solid Server" ;;
    prez)        http   prez        "$H:${PREZ_PORT:-8000}/health" "ok" ;;
    prez-ui)     http   prez-ui     "$H:${PREZ_UI_PORT:-8001}/" ;;
    grlc)        http   grlc        "$H:${GRLC_PORT:-8088}/api-local/swagger" '"swagger"' ;;
    grlc-query)  ACCEPT=application/json http grlc-query "$H:${GRLC_PORT:-8088}/api-local/services" "Fuseki" ;;
    graph-explorer) http graph-explorer "$H:${GRAPH_EXPLORER_PORT:-8095}/status" "OK" ;;
    pylode)      http   pylode      "$H:${PYLODE_PORT:-8096}/" "pyLODE" ;;
    pylode-render) http pylode-render "$H:${PYLODE_PORT:-8096}/pylode?url=http://landing/data/sample/semantic-stack-vocab.ttl" "Service" ;;
    rpt)         http   rpt         "$H:${RPT_PORT:-8642}/health" "ready" ;;
    rpt-query)   sparql rpt-query   "$H:${RPT_PORT:-8642}/sparql" ;;
    lp-etl)      http   lp-etl      "$H:${LP_ETL_PORT:-9080}/" ;;
    itb-shacl)   http   itb-shacl   "$H:${ITB_SHACL_PORT:-8097}/shacl/stack/api/info" '"domain"' ;;
    itb-validate) post  itb-validate "$H:${ITB_SHACL_PORT:-8097}/shacl/stack/api/validate" application/json \
                   "$(python3 -c 'import json; print(json.dumps({"contentToValidate": open("data/sample/semantic-stack.ttl").read(), "embeddingMethod": "STRING", "contentSyntax": "text/turtle", "validationType": "stack", "reportSyntax": "text/turtle"}))')" 'conforms' ;;
    prometheus)  http   prometheus  "$H:${PROMETHEUS_PORT:-9091}/-/ready" ;;
    sparql-exporter) http sparql-exporter "$H:${SPARQL_EXPORTER_PORT:-9199}/probe?target=http://fuseki:3030/ds/sparql&module=stack" "sparql_probe_success 1" ;;
    grafana)     http   grafana     "$H:${GRAFANA_PORT:-3000}/api/health" '"ok"' ;;
    sparql-mcp)  sse    sparql-mcp  "$H:${SPARQL_MCP_PORT:-8103}/sse" "event:" ;;
    rudof-mcp)   post   rudof-mcp   "$H:${RUDOF_MCP_PORT:-8102}/mcp" application/json \
                   '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}' "serverInfo" ;;
    open-ontologies) http open-ontologies "$H:${OPEN_ONTOLOGIES_PORT:-8101}/health" '"ok"' ;;
    graphrag)    http   graphrag    "$H:${FLEXIBLE_GRAPHRAG_PORT:-8104}/api/health" ;;
    graphrag-ui) http   graphrag-ui "$H:${FLEXIBLE_GRAPHRAG_UI_PORT:-8105}/ui/react/" ;;
    graphrag-mcp) post  graphrag-mcp "$H:${FLEXIBLE_GRAPHRAG_MCP_PORT:-3001}/mcp" application/json \
                   '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}' "serverInfo" ;;
    qdrant)      http   qdrant      "$H:${QDRANT_PORT:-6333}/collections" '"result"' ;;
    ollama)      http   ollama      "$H:${OLLAMA_PORT:-11434}/api/tags" '"models"' ;;
    *) bad "$c" "unknown check" ;;
  esac
done

echo
echo "$pass passed, $fail failed"
if [ "$fail" -gt 0 ]; then echo "Failed: ${failed[*]}"; exit 1; fi
