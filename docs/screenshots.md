# 📸 semantic-stack in pictures

Every UI in the stack, as the [screenshots workflow](../.github/workflows/screenshots.yml) captured it
on 2026-10-14: headless Chromium against the real containers, right after `make up && make load`
(the sample data, [`data/sample/`](../data/sample), is loaded). The groups below are the ones in
[`screenshots/targets.json`](../screenshots/targets.json); each profile group starts its profiles on top
of the default stack.

| Group | What runs | How to start it yourself |
|---|---|---|
| [Default stack](#default-stack) | the services every `make up` starts | `make up && make load` |
| [Store profiles](#store-profiles) | `qlever`, `oxigraph`, `graphdb`, `virtuoso`, `geosparql` | `make qlever-index` once, then `make qlever-up oxigraph-up graphdb-up virtuoso-up geosparql-up` |
| [API and tool profiles](#api-and-tool-profiles) | `prez`, `grlc`, `rpt`, `graph-explorer`, `docs`, `validation`, `ontop`, `solid` | `make prez-up grlc-up rpt-up graph-explorer-up docs-up validation-up ontop-up solid-up` |
| [Workbench profiles](#workbench-profiles) | `jupyter`, `observability`, `lp-etl` | `make jupyter-up observability-up lp-etl-up` |

Refreshing the pictures: `make screenshots` (one group at a time, `G="stores apis"` for the profile
groups) writes full-size captures and a gallery to `screenshots/out/`; `make screenshots-publish`
shrinks them into this folder. CI does both weekly: the `screenshots` artifact of the latest run is the
gallery, `screenshots-docs` is a drop-in replacement for `docs/screenshots/`.

---

## Default stack

### Landing page

<http://localhost:8080> · every service as a card, with a dot that turns green when your browser can
reach the port. Red dots are profiles that are not running.

![Landing page](screenshots/default/landing.png)

### Apache Jena Fuseki

<http://localhost:3030> (`admin` / `admin`) · the query tab of dataset `ds`. `make load` puts the sample
data in a named graph; the dataset's union default graph makes plain queries see it.

![Fuseki](screenshots/default/fuseki.png)

### Trifid

<http://localhost:8084> · the Linked Data frontend over Fuseki: start page, a dereferenced IRI from the
sample data (<http://localhost:8084/service/fuseki>, the stack describing itself), YASGUI on Trifid's
CORS-friendly `/query` proxy, and Graph Explorer, which lists the classes of the loaded graph and expands
nodes from any resource.

![Trifid home](screenshots/default/trifid-home.png)
![Trifid resource page](screenshots/default/trifid-resource.png)
![Trifid SPARQL console](screenshots/default/trifid-sparql.png)
![Trifid Graph Explorer](screenshots/default/trifid-graph-explorer.png)

### Blueprint

<http://localhost:8085> · Zazuko's knowledge-graph browser: the inventory lists the classes of the sample
graph; search and navigation go to Fuseki through Trifid's proxy.

![Blueprint](screenshots/default/blueprint.png)

### WebVOWL

<http://localhost:8083> · the bundled FOAF example. The OWL2VOWL converter behind it renders any ontology
you upload, for instance `data/sample/semantic-stack-vocab.ttl`.

![WebVOWL](screenshots/default/webvowl.png)

### RDF4J Workbench

<http://localhost:8082/rdf4j-workbench/repositories/NONE/server?workbench-server=http://127.0.0.1:8080/rdf4j-server>
· the repository list, with the Workbench pointed at the server URL it can reach from inside its container
(the link does that once, a cookie remembers it). The red bar is Chromium warning that browser-side XSLT is
being removed; the Workbench renders with XSLT, so expect it to need Firefox or a browser extension at some
point.

![RDF4J Workbench](screenshots/default/rdf4j-workbench.png)

### OpenRefine

<http://localhost:3333> · the create-project screen; `./data` is mounted read-only at `/import`.

![OpenRefine](screenshots/default/openrefine.png)

### sparql-proxy

<http://localhost:8090> · the proxy's own query editor. The dashboard with cache and job statistics is
`/admin` (`admin` / `admin`); `/sparql` is the read-only endpoint to hand to browser tools.

![sparql-proxy](screenshots/default/sparql-proxy.png)

### Sparklis

<http://localhost:8092> · compose a query by clicking through the data in plain English, starting from
"give me everything". The landing page opens it on sparql-proxy.

![Sparklis](screenshots/default/sparklis.png)

### Skosmos

<http://localhost:9090> · the "Semantic stack categories" thesaurus from `data/sample/semantic-stack-skos.ttl`.
Add your own vocabularies in `skosmos/config.ttl`.

![Skosmos](screenshots/default/skosmos.png)

### Sparnatural

<http://localhost:8094> · visual query builder; the class picker (Service, Category, Standard,
Organization) comes from the SHACL configuration in `sparnatural/config.ttl`.

![Sparnatural](screenshots/default/sparnatural.png)

### SHACL Play

<http://localhost:8091> · SHACL tools (validate, document, generate shapes), RDF dataset tools and SHACL
rules.

![SHACL Play](screenshots/default/shacl-play.png)

### pySHACL service

<http://localhost:8099/docs/swagger> · Swagger UI of the validation service; `POST /validate` takes
`data_graph` and `shapes_graph`.

![pySHACL Swagger UI](screenshots/default/pyshacl-swagger.png)

### Comunica

<http://localhost:8087/sparql> · the federated endpoint answering `SELECT * WHERE { ?s ?p ?o } LIMIT 10`
from Fuseki, as SPARQL JSON. Add more stores with `COMUNICA_SOURCES`.

![Comunica](screenshots/default/comunica.png)

---

## Store profiles

### QLever UI

Profile `qlever` · <http://localhost:7000> · the editor with the Olympics backend selected
(`make qlever-index` builds it); it autocompletes as you type.

![QLever UI](screenshots/stores/qlever-ui.png)

### Oxigraph

Profile `oxigraph` · <http://localhost:7878> · the built-in YASGUI.

![Oxigraph](screenshots/stores/oxigraph.png)

### GraphDB

Profile `graphdb` · <http://localhost:7200> · the Workbench welcome screen. Without a licence file GraphDB
runs in restricted mode; a free licence from Ontotext lifts that.

![GraphDB](screenshots/stores/graphdb.png)

### Virtuoso

Profile `virtuoso` · <http://localhost:8890/sparql> and the Conductor console at
<http://localhost:8890/conductor/> (`dba` / `dba`).

![Virtuoso SPARQL form](screenshots/stores/virtuoso-sparql.png)
![Virtuoso Conductor](screenshots/stores/virtuoso-conductor.png)

### Fuseki + GeoSPARQL

Profile `geosparql` · <http://localhost:3031> · a second Fuseki (Fuseki-main with Jena GeoSPARQL) with the
query UI and no admin pages; `data/sample/semantic-stack-geo.ttl` gives the organisations WKT points.

![Fuseki GeoSPARQL](screenshots/stores/fuseki-geosparql.png)

---

## API and tool profiles

### Prez

Profile `prez` · the OpenAPI docs at <http://localhost:8000/docs> and the Prez UI at
<http://localhost:8001> (data catalog, spatial catalog, vocabularies).

![Prez API docs](screenshots/apis/prez-api-docs.png)
![Prez UI](screenshots/apis/prez-ui.png)

### grlc

Profile `grlc` · <http://localhost:8088/api-local/> · a Swagger REST API generated from the `.rq` files in
`grlc/queries/` (`/dependencies`, `/services`, `/services_by_category`).

![grlc](screenshots/apis/grlc.png)

### RPT

Profile `rpt` · <http://localhost:8642> · the RDF Processing Toolkit server: SPARQL endpoint with YASGUI,
Snorql explorer, GraphQL endpoint.

![RPT](screenshots/apis/rpt.png)

### Graph Explorer

Profile `graph-explorer` · <http://localhost:8095/explorer> · AWS Graph Explorer connected to Fuseki; the
search panel already lists the sample organisations and places, ready to be added to the graph view.

![Graph Explorer](screenshots/apis/graph-explorer.png)

### pyLODE server

Profile `docs` · <http://localhost:8096> · `GET /pylode?url=…` renders any ontology reachable by URL.

![pyLODE server](screenshots/apis/pylode-server.png)

### ITB SHACL validator

Profile `validation` · <http://localhost:8097/shacl/stack/upload> · the upload form of the `stack`
validation domain defined in `itb/`.

![ITB SHACL validator](screenshots/apis/itb-shacl.png)

### Ontop

Profile `ontop` · <http://localhost:8089> · the SPARQL portal of the virtual knowledge graph over Postgres.

![Ontop portal](screenshots/apis/ontop-portal.png)

### Community Solid Server

Profile `solid` · <http://localhost:8100> · the server's welcome page; sign up to create a Pod.

![Community Solid Server](screenshots/apis/solid.png)

---

## Workbench profiles

### JupyterLab

Profile `jupyter` · <http://localhost:8888/lab> · the launcher, with the starter notebook and `data/`
in the file browser.

![JupyterLab](screenshots/workbench/jupyterlab.png)

### Grafana and Prometheus

Profile `observability` · <http://localhost:3000> (anonymous viewer) and the Prometheus targets page at
<http://localhost:9091/targets>, showing Prometheus itself and the SPARQL exporter.

![Grafana](screenshots/workbench/grafana.png)
![Prometheus targets](screenshots/workbench/prometheus-targets.png)

### LinkedPipes ETL

Profile `lp-etl` · <http://localhost:9080> · the execution list after `make lp-etl-run`, the example
pipeline ([`lp-etl/pipelines/semantic-stack.jsonld`](../lp-etl/README.md): download the sample data and
shapes, SHACL-validate, derive the dependency closure with SPARQL CONSTRUCT, load it into Fuseki) on the
canvas, and the same canvas in execution mode, every component green.

![LinkedPipes ETL](screenshots/workbench/lp-etl.png)
![LinkedPipes ETL pipeline](screenshots/workbench/lp-etl-pipeline.png)
![LinkedPipes ETL execution](screenshots/workbench/lp-etl-execution.png)
