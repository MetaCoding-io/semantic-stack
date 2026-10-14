# 🧱 semantic-stack

[![smoke](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/smoke.yml/badge.svg)](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/smoke.yml)
[![publish-images](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/publish-images.yml/badge.svg)](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/publish-images.yml)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Docker Compose](https://img.shields.io/badge/docker-compose-2496ED?logo=docker&logoColor=white)](compose.yml)

**A turnkey semantic web / knowledge graph stack in one `docker compose up`.**
Apache Jena Fuseki as the store, a caching SPARQL proxy, a Linked Data frontend, ontology
visualisation, a visual query builder, a SKOS vocabulary browser, data transformation, federated
querying, SHACL validation and schema-first modelling, each on its own port, with sample data and
a smoke test that proves every service answers. Extra engines (QLever, Oxigraph, GraphDB) and
tools are one profile away.

A [MetaCoding](https://metacoding.io) project: the local stack behind our data-centric consulting
work and the environment [SemanticSeams](https://github.com/MetaCoding-io/SemanticSeams) is
developed against.

---

## 📚 Table of contents

- [🚀 Quick start](#-quick-start)
- [🎛️ Choose your stack](#️-choose-your-stack)
- [🧩 Services by category](#-services-by-category)
- [🔌 SPARQL endpoints](#-sparql-endpoints)
- [📥 Loading your own data](#-loading-your-own-data)
- [⚙️ Configuration](#️-configuration)
- [📸 Screenshots](#-screenshots)
- [🗂️ Repository layout](#️-repository-layout)
- [⚠️ Known limitations](#️-known-limitations)
- [🔁 Keeping it fresh](#-keeping-it-fresh)
- [🧭 Roadmap](#-roadmap)

---

## 🚀 Quick start

```bash
git clone https://github.com/MetaCoding-io/semantic-stack.git && cd semantic-stack
make up      # start the stack (first run builds WebVOWL, OpenRefine, SHACL Play and pySHACL, several minutes)
make load    # load data/sample into Fuseki
make smoke   # every service answers?
```

Then open the **landing page** at <http://localhost:8080>. It links every service and shows a
green dot next to the ones your browser can reach. Try a query in the
[SPARQL console](http://localhost:8084/sparql), or dereference
<http://localhost:8084/service/fuseki> to see Linked Data working end to end.

> 💡 No `make`? Every target is a one-liner; `make help` prints them.
> `docker compose pull webvowl openrefine shacl-play pyshacl` fetches the prebuilt images instead of building.

---

## 🎛️ Choose your stack

One `compose.yml`. The **default** is complete on its own; **profiles** add engines and tools.

### ✅ Default

```bash
make up && make load
```

| Service | Role |
|---|---|
| **Fuseki** | The store. SPARQL 1.1/1.2 Query and Update, Graph Store Protocol, SHACL, text index. Everything else points here. |
| **Trifid** | Linked Data frontend over Fuseki: dereferenceable IRIs, SPARQL console, Graph Explorer, CORS proxy |
| **Blueprint** | Knowledge graph browser (through Trifid's proxy) |
| **Comunica** | Federated SPARQL endpoint, over Fuseki by default |
| **sparql-proxy** | Caching, job-queueing, update-rejecting proxy over Fuseki: the read-only endpoint for browser tools |
| **Sparklis** | Visual query builder over Fuseki (through sparql-proxy) |
| **Skosmos** | SKOS vocabulary browser and REST API over Fuseki |
| **SHACL Play**, **pySHACL service**, **SPARQL Anything** | SHACL validation and documentation, SHACL over HTTP, SPARQL over CSV/JSON/XML files |
| **WebVOWL**, **RDF4J Workbench**, **OpenRefine** | Ontology visualisation, repository management, data cleaning |
| **Landing page** | Links and live reachability for all of the above |

Why Fuseki first: it accepts writes out of the box, needs no indexing step, ships SHACL and a
text index, and is the implementation most tutorials and client stacks assume.

### ➕ Profiles

```bash
docker compose --profile <name> up -d        # or: make <name>-up
```

| Profile | `make` | Adds | Pick it when |
|---|---|---|---|
| 🏎️ `qlever` | `make qlever-up` | **QLever** + **QLever UI** serving the Olympics demo (1.8M triples). Builds the index on first run. | You want to see a Wikidata-scale engine, or you have a large, read-mostly graph |
| 🦀 `oxigraph` | `make oxigraph-up` | **Oxigraph**, a lightweight Rust store with a built-in YASGUI | You want a second writable store for comparison, or something tiny for tests |
| 🏢 `graphdb` | `make graphdb-up` | **Ontotext GraphDB** Free | Your clients run GraphDB and you want a faithful mirror |
| 🧰 `tools` | `make tools` | Shell in the **Python toolbox** (rdflib, pySHACL, OWL-RL, SPARQLWrapper, LinkML, pyLODE, pandas, jelly-cli) plus the **RMLMapper**, **YARRRML**, **SDM-RDFizer**, **rudof** and **EYE** CLIs, `./data` mounted at `/data` | You want to validate, convert, reason, model or script |
| 📓 `jupyter` | `make jupyter-up` | **JupyterLab** with the same toolbox and `notebooks/01-hello-stack.ipynb` | You prefer notebooks |
| 🪞 `ontop` | `make ontop-up` | **Postgres** (seeded demo tables) + **Ontop** virtual knowledge graph: SPARQL over SQL, nothing copied | You have relational data and want it as RDF without an ETL |
| 🐘 `virtuoso` | `make virtuoso-up` | **OpenLink Virtuoso Open Source** on <http://localhost:8890> (SPARQL at `/sparql`, Conductor at `/conductor`, `dba`/`dba`); `make load` fills it | Your clients run Virtuoso (DBpedia, most of the LOD cloud) |
| 🌍 `geosparql` | `make geosparql-up` | **Fuseki + GeoSPARQL** (Zazuko build, Jena 6.2) on <http://localhost:3031>; `make load` fills it, `data/queries/40-geosparql-nearby.rq` uses the WKT sample | You have geometries and want `geof:` functions and a spatial index |
| 🔗 `prez` | `make prez-up` | **Prez** Linked Data API on <http://localhost:8000> (OpenAPI at `/docs`, `/object?uri=…`) + **Prez UI** on <http://localhost:8001> | You want a profile-driven, content-negotiating API over the store |
| 🧾 `grlc` | `make grlc-up` | **grlc** on <http://localhost:8088/api-local/>: every `.rq` in `grlc/queries` becomes a documented REST route | You want REST endpoints for people who will never write SPARQL |
| 🕸️ `graph-explorer` | `make graph-explorer-up` | **AWS Graph Explorer** on <http://localhost:8095/explorer>, click-to-expand instance graph | You want to show a graph to someone, not a result table |
| 📄 `docs` | `make docs-up` | **pyLODE server** on <http://localhost:8096>: ontology documentation by URL | You want docs for an ontology without the CLI |
| 🧮 `rpt` | `make rpt-up` | **RDF Processing Toolkit** server on <http://localhost:8642>: YASGUI, GraphQL and a Linked Data viewer over Fuseki | You want GraphQL over SPARQL, or RPT's SPARQL-sequence pipelines |
| 🪈 `lp-etl` | `make lp-etl-up` | **LinkedPipes ETL** on <http://localhost:9080>, four containers | You want to draw ETL pipelines instead of scripting them |
| ✅ `validation` | `make validation-up` | **ITB SHACL validator** on <http://localhost:8097/shacl/stack/upload>: web form, REST and SOAP over `data/sample/shapes.ttl` | You need validation as a service for other teams or systems |
| 📈 `observability` | `make observability-up` | **Prometheus** (<http://localhost:9091>) + **sparql-prometheus-exporter** (SPARQL counts as gauges) + **Grafana** (<http://localhost:3000>, SPARQL datasource provisioned) | You want dashboards over the data or the stores |
| 🤖 `mcp` | `make mcp-up` | **sparql-mcp** (SPARQL 1.1 + Graph Store over Fuseki, SSE on :8103), **rudof-mcp** (ShEx/SHACL/SPARQL, :8102), **open-ontologies** (ontology engineering, :8101) | You want Claude Code or another agent to work with the stack, see below |
| 🧠 `graphrag` | `make graphrag-up` | **Flexible GraphRAG** + **Qdrant**: LLM knowledge-graph extraction into Fuseki, hybrid search, chat UI (<http://localhost:8105>) and MCP (:3001); needs `ANTHROPIC_API_KEY` or the `ollama` profile | You want to try GraphRAG over RDF with your own documents |
| 🦙 `ollama` | `make ollama-up` | **Ollama** on <http://localhost:11434>, local models with an OpenAI-compatible API | You want the `graphrag` profile without an API key |
| 🟣 `solid` | `make solid-up` | **Community Solid Server** on <http://localhost:8100>: a Solid Pod / LDP server | You develop Solid apps or need an LDP server |

Profiles combine freely (`docker compose --profile qlever --profile oxigraph up -d`, or
`make profile P=<name>`). Put `COMPOSE_PROFILES=qlever,oxigraph` in `.env` to make them part of your
default `make up`. The last nine profiles come from the [October 2026 tool survey](reports/); every
profile has its own smoke job in CI.

<details>
<summary>Hooking the MCP servers up to Claude Code</summary>

```bash
make mcp-up
claude mcp add --transport sse  sparql          http://localhost:8103/sse    # SELECT/ASK/CONSTRUCT, Update, Graph Store, SHACL over Fuseki
claude mcp add --transport http rudof           http://localhost:8102/mcp    # load RDF (files or endpoints), SPARQL, ShEx/SHACL validation
claude mcp add --transport http open-ontologies http://localhost:8101/mcp    # ontology editing with reasoning and change certificates
# read-only agent: point sparql-mcp at the proxy instead of Fuseki
#   SPARQL_MCP_QUERY_URL=http://sparql-proxy:3000/sparql in .env (updates are then rejected)
```

Two more worth knowing that are not containers here: `claude mcp add qlever -- npx -y mcp-server-qlever@0.3.0 -e http://localhost:7001`
(QLever-aware tools, stdio) and `claude mcp add --transport http wikidata https://wd-mcp.wmcloud.org/mcp`
(Wikimedia Deutschland's hosted Wikidata MCP).

</details>

<details>
<summary>Pointing Trifid, Blueprint, Comunica or sparql-proxy at another store</summary>

All of them follow Fuseki by default. Four variables in `.env` move them:

```bash
TRIFID_SPARQL_ENDPOINT_URL=http://qlever:7001          # Trifid (and Blueprint through its proxy)
TRIFID_DATASET_BASE_URL=http://wallscope.co.uk/        # base of the IRIs in that store (Olympics data)
BLUEPRINT_FTS_DIALECT=qlever                           # fuseki | qlever | stardog | graphdb | neptune
COMUNICA_SOURCES="sparql@http://fuseki:3030/ds/sparql sparql@http://qlever:7001"   # space-separated
SPARQL_PROXY_BACKEND=http://qlever:7001                # sparql-proxy, and Sparklis through it
```

Comunica fails a federated query if any listed source is down, so only list stores whose profile is up.

</details>

<details>
<summary>Which store does each tool talk to?</summary>

Every tool here speaks plain SPARQL 1.1 or works on files, so none is tied to one engine.

| Tool | Talks to | How to change it |
|---|---|---|
| Trifid, Blueprint, Comunica, sparql-proxy | Fuseki | the `.env` variables above |
| Sparklis, Sparnatural | sparql-proxy | browser apps; Sparklis takes `?endpoint=`, Sparnatural's is the `endpoint` attribute in `sparnatural/index.html` |
| Prez, grlc, RPT, Graph Explorer, sparql-mcp, Grafana's SPARQL datasource | Fuseki | `PREZ_SPARQL_ENDPOINT`, `GRLC_SPARQL_ENDPOINT`, `RPT_SPARQL_ENDPOINT`, `GRAPH_EXPLORER_CONNECTION_URL`, `SPARQL_MCP_*_URL` in `.env`; Grafana in `grafana/provisioning/` |
| Virtuoso, Fuseki + GeoSPARQL | themselves | separate stores; `scripts/load.sh` fills both when they run |
| Flexible GraphRAG | Fuseki, its own dataset `flexible-graphrag` | created through Fuseki's admin API; plus Qdrant for vectors |
| Skosmos | Fuseki `ds` | `skosmos/config.ttl` (`skosmos:sparqlEndpoint`); `Generic` dialect works on Oxigraph, GraphDB or QLever too |
| RDF4J Workbench | any | add a "SPARQL endpoint proxy" repository by container URL |
| SHACL Play, pySHACL service | none (uploads) | SHACL Play's *Generate* page can read any endpoint by container URL |
| SPARQL Anything | files in `/data` | `SERVICE <x-sparql-anything:...>`; federate to any endpoint with a second `SERVICE` |
| RMLMapper, SDM-RDFizer, rudof, EYE, jelly-cli, toolbox | files in `/data` | load the output with `scripts/load.sh`; `rudof` and the toolbox can also query endpoints directly |

</details>

---

## 🧩 Services by category

### 🗄️ Triple stores

| Service | URL | Notes |
|---|---|---|
| **Apache Jena Fuseki** | <http://localhost:3030> | **Default store.** SPARQL 1.1/1.2 Query + Update, Graph Store Protocol, SHACL endpoint, text index. Login `admin` / `admin`. |
| **QLever** | <http://localhost:7001> | Profile `qlever`. Very fast engine for large, read-mostly graphs; indexed once. API only, use the QLever UI. |
| **Oxigraph** | <http://localhost:7878> | Profile `oxigraph`. Rust, zero setup, built-in YASGUI. |
| **GraphDB** | <http://localhost:7200> | Profile `graphdb`. Ontotext GraphDB Free. |
| **Virtuoso** | <http://localhost:8890/sparql> | Profile `virtuoso`. OpenLink Virtuoso Open Source 7.2; Conductor at `/conductor` (`dba` / `dba`), isql on 1111. GPL-2.0. |
| **Fuseki + GeoSPARQL** | <http://localhost:3031/ds/sparql> | Profile `geosparql`. Fuseki-main with Jena GeoSPARQL and Apache SIS; same Jena as the main Fuseki, no admin UI. |
| **Community Solid Server** | <http://localhost:8100> | Profile `solid`. Solid Pod / LDP server, not a SPARQL store. |

### 🔍 Query and federate

| Service | URL | Notes |
|---|---|---|
| **Trifid SPARQL console** | <http://localhost:8084/sparql> | YASGUI against Fuseki, via Trifid's CORS-friendly `/query` proxy. |
| **Comunica** | <http://localhost:8087/sparql> | One federated SPARQL endpoint; Fuseki by default, add other stores with `COMUNICA_SOURCES`. |
| **Sparnatural** | <http://localhost:8094> | SHACL-configured visual query builder (`sparnatural/config.ttl` describes the sample data); queries go through sparql-proxy. |
| **grlc** | <http://localhost:8088/api-local/> | Profile `grlc`. Swagger REST API generated from `grlc/queries/*.rq`. |
| **RPT** | <http://localhost:8642/sparql> | Profile `rpt`. YASGUI, GraphQL (`/graphql`) and a Linked Data viewer over Fuseki. |
| **Prez** | <http://localhost:8000/docs> | Profile `prez`. Linked Data API with profiles, search and `/object?uri=`; UI on <http://localhost:8001>. |
| **sparql-proxy** | <http://localhost:8090/sparql> | Caching, job-queueing, update-rejecting proxy over Fuseki; dashboard at `/admin` (`admin` / `admin`). The endpoint to hand to browser tools and read-only users. |
| **Sparklis** | <http://localhost:8092> | Visual query builder: compose SPARQL by clicking through the data in plain English. The landing page opens it on sparql-proxy. |
| **QLever UI** | <http://localhost:7000> | Profile `qlever`. Query editor with autocompletion, preconfigured for the QLever above. |
| **RDF4J Workbench** | <http://localhost:8082/rdf4j-workbench/NONE/server?workbench-server=http://localhost:8080/rdf4j-server> | Repository manager; add any store as a "SPARQL endpoint proxy". The link sets the Workbench's server to the container-internal URL once (cookie); opening `/rdf4j-workbench/` directly makes it look for the server on the host port and fail. |
| **Ontop** | <http://localhost:8089/sparql> | Profile `ontop`. SPARQL over a relational database. |

### 🧭 Browse and visualise

| Service | URL | Notes |
|---|---|---|
| **Landing page** | <http://localhost:8080> | Every service with a live reachability check. |
| **Trifid** | <http://localhost:8084> | Linked Data frontend over Fuseki: dereferenceable IRIs (<http://localhost:8084/service/fuseki> after `make load`), Graph Explorer at `/graph-explorer`. |
| **Blueprint** | <http://localhost:8085> | Knowledge graph browser (needs a Blueprint configuration graph, see limitations). |
| **WebVOWL** | <http://localhost:8083> | OWL ontology visualisation with the OWL2VOWL converter. Try `data/sample/semantic-stack-vocab.ttl`. |
| **Skosmos** | <http://localhost:9090> | SKOS vocabulary browser and REST API over Fuseki. Shows `data/sample/semantic-stack-skos.ttl` after `make load`; add your own vocabularies in `skosmos/config.ttl`. |
| **Graph Explorer** | <http://localhost:8095/explorer> | Profile `graph-explorer`. AWS Graph Explorer: expand nodes and edges interactively; the container queries Fuseki through its own proxy. |

### 🔄 Transform and map

| Service | How | Notes |
|---|---|---|
| **OpenRefine** | <http://localhost:3333> | Interactive data cleaning; `./data` is mounted read-only at `/import`. |
| **RMLMapper** | `docker compose --profile tools run --rm rmlmapper …` | CSV/JSON/XML → RDF with RML or R2RML. |
| **YARRRML parser** | `docker compose --profile tools run --rm yarrrml …` | Human-friendly YAML → RML. Walkthrough in [data/rml/README.md](data/rml/README.md). |
| **SDM-RDFizer** | `docker compose --profile tools run --rm sdm-rdfizer` | Second RML engine (100 % on every module of the new RML spec in the 2026 KGCW challenge); runs the same mapping via `data/rml/sdm-rdfizer.ini`. |
| **SPARQL Anything** | <http://localhost:8093/sparql> | Query CSV, JSON, XML, HTML, spreadsheets, … as RDF with no mapping (Facade-X). Endpoint `/sparql.anything`; try `data/queries/30-sparql-anything-csv.rq`. |
| **RPT CLI** | `docker compose --profile tools run --rm rpt-cli rmltk rml to sparql rml/mapping.rml.ttl` | RML → SPARQL CONSTRUCT, SPARQL-sequence pipelines, `integrate <data> <query.rq>`. |
| **LinkedPipes ETL** | <http://localhost:9080> | Profile `lp-etl`. Visual pipelines: download, SPARQL transform, SHACL, upload to a SPARQL endpoint. |
| **Flexible GraphRAG** | <http://localhost:8105> | Profile `graphrag`. Documents → LLM-extracted knowledge graph in Fuseki + Qdrant, hybrid search, chat, MCP. |
| **Ontop** | profile `ontop` | Keep the data in SQL, query it as RDF. |

### 🧪 Validate, model, document

| Tool | How | Notes |
|---|---|---|
| **pySHACL** | `docker compose --profile tools run --rm tools pyshacl -s sample/shapes.ttl sample/semantic-stack.ttl` | Also as an HTTP service at <http://localhost:8099/docs/swagger> (`POST /validate` with `data_graph` and `shapes_graph`) and as Fuseki's `/ds/shacl` endpoint. |
| **SHACL Play** | <http://localhost:8091> | Validate with readable reports, document shapes as HTML and UML, generate shapes from data, OWL → SHACL, SHACL rules. |
| **rudof** | `… rudof shacl-validate --shapes sample/shapes.ttl sample/semantic-stack.ttl` | ShEx + SHACL + DCTAP validation and conversion in one binary. `make validate` runs pySHACL and rudof. |
| **EYE** | `… eye --quiet --nope n3/socrates.n3 --pass` | Notation3 reasoner; `data/n3/socrates.n3` is the classic example. |
| **jelly-cli** | `… tools sh -c 'jelly-cli rdf to-jelly sample/semantic-stack.ttl > out/semantic-stack.jelly'` | Jelly binary RDF streaming, readable by Jena, RDF4J, Morph-KGC and TopQuadrant SHACL. |
| **ROBOT** | `… robot reason --reasoner ELK --input sample/semantic-stack-vocab.ttl --output out/vocab-reasoned.ttl` | OBO Foundry OWL toolkit: reason, `report` (QC), convert, merge, extract. |
| **Nemo** | `… nemo -D out -o nemo/dependencies.rls` | Datalog rule engine over RDF files and SPARQL endpoints; `data/nemo/dependencies.rls` derives the transitive dependency closure. |
| **WIDOCO** | `… widoco -ontFile data/sample/semantic-stack-vocab.ttl -outFolder data/out/widoco -rewriteAll -webVowl -uniteSections -lang en` | Wizard-style ontology documentation with an embedded WebVOWL view; browse the output at <http://localhost:8080/data/out/widoco/doc/>. |
| **pyLODE server** | <http://localhost:8096> | Profile `docs`. `GET /pylode?url=…` renders any ontology reachable by URL; the landing page serves `./data` at `http://landing.internal/data/…` for that. |
| **ITB SHACL validator** | <http://localhost:8097/shacl/stack/upload> | Profile `validation`. Web form, REST (`POST /shacl/stack/api/validate`) and SOAP; domains live in `itb/`. |
| **Grafana + Prometheus** | <http://localhost:3000> | Profile `observability`. SPARQL datasource over Fuseki; `prometheus/sparql-exporter.yml` turns SPARQL counts into metrics. |
| **LinkML** | `… tools gen-owl linkml/semantic-stack.yaml` | One YAML model → OWL, SHACL, JSON Schema, Pydantic (`gen-owl`, `gen-shacl`, `gen-json-schema`, `gen-pydantic`). |
| **pyLODE** | `… tools pylode sample/semantic-stack-vocab.ttl -o out/vocab.html` | HTML documentation for an ontology. |
| **Jena CLI** | `docker compose exec fuseki /jena/bin/riot --validate /data/sample/semantic-stack.ttl` | `riot`, `sparql`, `shacl` and friends ship inside the Fuseki image. |
| **JupyterLab** | profile `jupyter` | Everything above as a notebook kernel. |

Every image is pinned. Fuseki 6.2 (Jena 6), RDF4J 6.1, Oxigraph 0.5 and Comunica 5 support
RDF 1.2 and SPARQL 1.2.

---

## 🔌 SPARQL endpoints

| Store | Container URL (from other services) | Browser URL | Update |
|---|---|---|---|
| Fuseki | `http://fuseki:3030/ds/sparql` | `http://localhost:3030/ds/sparql` | `/ds/update`, `/ds/data` |
| QLever (profile) | `http://qlever:7001` | `http://localhost:7001` | re-index (`make qlever-index`) |
| Oxigraph (profile) | `http://oxigraph:7878/query` | `http://localhost:7878/query` | `/update`, `/store` |
| Comunica | `http://comunica:8080/sparql` | `http://localhost:8087/sparql` | no |
| Trifid proxy | `http://trifid:8080/query` | `http://localhost:8084/query` | no |
| sparql-proxy | `http://sparql-proxy:3000/sparql` | `http://localhost:8090/sparql` | rejected by design |
| Virtuoso (profile) | `http://virtuoso:8890/sparql` | `http://localhost:8890/sparql` | `/sparql-graph-crud-auth` (digest auth `dba`) |
| Fuseki + GeoSPARQL (profile) | `http://fuseki-geosparql:3030/ds/sparql` | `http://localhost:3031/ds/sparql` | `/ds/update`, `/ds/data` |
| RPT (profile) | `http://rpt:8642/sparql` | `http://localhost:8642/sparql` | no (proxy) |
| SPARQL Anything | `http://sparql-anything:3000/sparql.anything` | `http://localhost:8093/sparql.anything` | no (files) |
| Ontop | `http://ontop:8080/sparql` | `http://localhost:8089/sparql` | no (virtual) |

> 🧭 **Browser URLs versus container URLs.** Services talk to each other by service name
> (`http://fuseki:3030/…`). Anything that runs in your browser (Blueprint, the QLever UI's backend
> setting, YASGUI) must use `localhost` and the host port. Getting this wrong is the usual reason a
> service "starts but shows nothing".

---

## 📥 Loading your own data

| Where | How |
|---|---|
| **Fuseki** (and Oxigraph, Virtuoso, Fuseki + GeoSPARQL when up) | `./scripts/load.sh my-file.ttl` posts to a named graph over the Graph Store Protocol of every running store. Or use the Fuseki UI (upload), `/ds/update`, or Oxigraph's YASGUI. |
| **QLever** | Copy your `.ttl`/`.nt` into `./qlever/`, edit `qlever/Qleverfile` (`NAME`, `INPUT_FILES`, drop `GET_DATA_CMD`), then `make qlever-index` and `docker compose --profile qlever restart qlever qlever-ui`. |
| **From CSV/JSON/XML** | Write a YARRRML mapping, run `yarrrml` then `rmlmapper` ([data/rml/README.md](data/rml/README.md)), load the output. |
| **From a SQL database** | Point the `ontop` profile at it: edit `ontop/input/mapping.obda` and the `ONTOP_DB_*` variables. Nothing gets copied. |
| **Skip the mapping** | Query the file directly with SPARQL Anything: `data/queries/30-sparql-anything-csv.rq` reads `data/rml/services.csv` as RDF. |
| **Validate first** | `make validate` (pySHACL and rudof), SHACL Play at <http://localhost:8091/validate>, `POST` to the pySHACL service at `:8099/validate`, or POST shapes to Fuseki's `/ds/shacl`. |
| **Publish a vocabulary** | Load a SKOS file into a named graph in Fuseki and add a `skosmos:Vocabulary` block to `skosmos/config.ttl` (its comments explain each property). |

> ℹ️ Fuseki's `ds` dataset treats the default graph as the union of all named graphs, so load into
> a named graph (the script does) rather than the default graph.

Sample data, example queries, RML and LinkML examples live in [`data/`](data/README.md).

---

## ⚙️ Configuration

Copy `.env.example` to `.env` to change ports, passwords, default profiles (`COMPOSE_PROFILES`)
or which store Trifid, Comunica and sparql-proxy use. Every value has a default inside `compose.yml`, so `.env`
is optional.

On Linux, QLever writes its index into `./qlever` as `QLEVER_UID:QLEVER_GID` (default `1000:1000`).
`make` fills these from `id -u` / `id -g` automatically; when calling `docker compose` directly with
another uid, set them in `.env`.

`examples/compose.external-network.yml` shows how to attach the stores to a network owned by
another compose project (for example a monorepo whose services need `http://fuseki:3030`).

---

## 📸 Screenshots

Every UI in the stack can be captured with a headless Chromium, grouped the same way as the
profiles (`screenshots/targets.json`):

```bash
make up && make load
make screenshots                         # default group -> screenshots/out/index.html
make screenshots G="stores apis"         # profile groups (start their profiles first)
```

The [screenshots workflow](.github/workflows/screenshots.yml) does the same in CI, weekly and on
demand: one job per group against the real containers, stitched into a `screenshots` artifact with
a gallery page. Open the latest run under *Actions > screenshots* and download the artifact.

---

## 🗂️ Repository layout

```text
.
├── compose.yml                  # the stack: default services + profiles (qlever, oxigraph, graphdb, tools, jupyter, ontop)
├── Makefile                     # make help
├── .env.example                 # ports, passwords, default profiles, which store Trifid/Comunica use
│
├── data/                        # mounted at /data in most containers; drop your files here
│   ├── sample/
│   │   ├── semantic-stack.ttl           # demo dataset: the stack describing itself
│   │   ├── semantic-stack-vocab.ttl     # its vocabulary (WebVOWL, pyLODE, Ontop ontology)
│   │   ├── semantic-stack-skos.ttl      # the tool categories as a SKOS thesaurus (Skosmos)
│   │   ├── semantic-stack-geo.ttl       # WKT points for the organisations (geosparql profile)
│   │   └── shapes.ttl                   # SHACL shapes for the demo data
│   ├── queries/                 # 01-03 sample data · 10-11 Olympics (QLever) · 20 federated · 30 SPARQL Anything
│   ├── rml/                     # services.csv + YARRRML mapping + SDM-RDFizer config, with README
│   ├── n3/socrates.n3           # Notation3 rules for EYE
│   ├── nemo/dependencies.rls    # Datalog rules for Nemo
│   ├── linkml/semantic-stack.yaml       # same model as a LinkML schema
│   └── out/                     # generated files (git-ignored)
│
├── screenshots/                 # headless-browser screenshots: take.mjs, targets.json (make screenshots)
├── scripts/
│   ├── load.sh                  # load data/sample into Fuseki (and Oxigraph when running)
│   └── smoke.sh                 # every service answers? used by CI and `make smoke`
│
├── landing/index.html           # landing page with live reachability dots
├── qlever/Qleverfile            # QLever dataset config for the qlever profile (Olympics demo, port 7001)
├── qlever-ui/configure-and-run.sh   # points the QLever UI at this server on start
│
├── openrefine/Dockerfile        # OpenRefine from the official release tarball
├── webvowl/Dockerfile           # WebVOWL + OWL2VOWL built from upstream source
├── shacl-play/Dockerfile        # SHACL Play built from upstream source at a pinned release
├── pyshacl/Dockerfile           # pySHACL HTTP service from the pinned PyPI release
├── skosmos/config.ttl           # Skosmos endpoint + vocabulary configuration
├── sparnatural/                 # Sparnatural static site: index.html + SHACL config for data/sample
├── fuseki-geosparql/config.ttl  # Fuseki-main assembler for the geosparql profile (adds update endpoints)
├── grlc/queries/                # .rq files with #+ headers that grlc serves as a REST API
├── itb/stack/                   # ITB SHACL validator domain (validation profile)
├── prometheus/ grafana/         # scrape config, SPARQL exporter modules, Grafana datasource provisioning
├── pylode/ sparql-mcp/ flexible-graphrag-mcp/   # Dockerfiles for the docs, mcp and graphrag profiles
├── graphrag/nginx.conf          # one port for the GraphRAG UI and API
├── tools/                       # Python toolbox image (+ jelly-cli): Dockerfile, requirements.in, requirements.txt
├── ontop/                       # Dockerfile (adds the Postgres JDBC driver), input/ mapping, postgres/ seed
├── notebooks/01-hello-stack.ipynb   # JupyterLab starter
│
├── examples/compose.external-network.yml   # join another compose project's network
├── reports/, research_notes/    # the October 2026 tool survey this selection is based on
├── .devcontainer/devcontainer.json         # VS Code dev container on the toolbox image
└── .github/
    ├── workflows/smoke.yml      # default stack + one job per profile, on every PR and weekly
    ├── workflows/publish-images.yml   # pushes the locally built images to GHCR
    ├── workflows/screenshots.yml      # screenshots of every UI, weekly and on demand
    └── dependabot.yml           # compose images, Dockerfiles, pip, Actions
```

`rdflib-orm` is a git submodule (`git submodule update --init`): an experimental Python ORM for
RDF by MetaCoding, kept here for convenience and not used by the stack itself.

---

## ⚠️ Known limitations

- **Blueprint** shows an empty screen until a Blueprint configuration graph describing your data
  is in the store. Zazuko's [demo stack](https://github.com/zazuko/blueprint/tree/main/stack) is
  the reference; it is not wired up here yet.
- **WebVOWL** is unmaintained upstream (last release 2019). The image is built from the upstream
  Docker build added in 2026, cloning WebVOWL and OWL2VOWL from source, because the old `.war`
  download is gone. `webvowl/Dockerfile` has build args to point at a fork.
- **OpenRefine** has no official container image; `openrefine/Dockerfile` installs the official
  release tarball. The RDF extension is not bundled.
- **GraphDB 11** starts in Free mode. If it asks for a licence, request the free one from Ontotext
  and upload it under Setup > License.
- **QLever** (profile) publishes no release tags, only `latest` and per-commit tags, so the stack
  pins a commit tag. Dependabot will not bump it; do so by hand. Its SPARQL Update support needs
  an access token and lives on top of the prebuilt index, which is why it is not the default.
- **sparql-proxy** and **Sparklis** publish no release tags either: the proxy is pinned to a
  `snapshot-*` tag, Sparklis by digest (its only image dates from January 2023, older than the
  current source). Bump both by hand.
- **Sparklis, rudof, EYE and SDM-RDFizer** ship amd64 images only; on Apple Silicon they run under
  emulation (`platform: linux/amd64` is set).
- **SPARQL Anything** is pinned to the 1.2.0 release. 1.3.0 (release candidates since October 2026)
  renames `fx:root` to `fx:Root` and moves engine options to the `fxe:` namespace; bump when it is final.
- **Skosmos** uses the plain-SPARQL `Generic` dialect against Fuseki's `ds` dataset, so search is
  regex-based. For large vocabularies create a dedicated Fuseki dataset with a jena-text index over
  the SKOS label properties and switch `skosmos/config.ttl` to the `JenaText` dialect.
- **Sparnatural** and **Grafana** load their JavaScript bundles and plugin from CDNs / grafana.com on
  first use, so those two need internet access; vendor the files for offline use.
- **Prez UI 3.8.3** is the last generic UI image; the 4.x UI is generated per site, so the UI may
  lag the 4.25 API. **grlc, Graph Explorer, RPT, Virtuoso's isql client** and the MCP images are
  amd64-only. **LinkedPipes ETL** images are dated snapshots of `main` (no releases) and the
  **sparql-mcp** image is built from a pinned commit (no releases either).
- **Flexible GraphRAG** needs a real LLM: set `ANTHROPIC_API_KEY` in `.env` or start the `ollama`
  profile and set `GRAPHRAG_LLM_PROVIDER=ollama`. The backend image is about 4 GB. Its Fuseki dataset
  is created through the admin API and is not persisted across Fuseki configuration volumes.
- **Virtuoso** is GPL-2.0; fine to run, mind it if you redistribute a derived image.
- **Looked at, not bundled:** Quit Store (git-versioned RDF; last release 2022), iQvoc (only image is
  from 2022), OLS4 (needs a Docker-socket-driven Nextflow data load), sparql-llm (build-only, prompts
  tied to SIB's endpoints), WikidataMCP (hosted at `https://wd-mcp.wmcloud.org/mcp`), rareba/sparql-mcp
  (stdio, not on PyPI). Details in [`reports/`](reports/) and `research_notes/`.
- **Default credentials** (`admin`/`admin`, `stack`/`stack`) are for local use. Change them in
  `.env` before exposing any port.

---

## 🔁 Keeping it fresh

- **CI** ([smoke.yml](.github/workflows/smoke.yml)) brings up the default stack and, in parallel,
  the QLever (with a real index), Oxigraph and Ontop profiles, the tools image and one job per
  optional profile (virtuoso, geosparql, prez, grlc, graph-explorer, docs, rpt, lp-etl, validation,
  observability, mcp, solid; graphrag and ollama are config-checked only) on every PR and weekly,
  and fails if any service stops answering. It pulls the published images and rebuilds one
  only when its Dockerfile changed, so a run takes about two minutes.
- **Dependabot** ([dependabot.yml](.github/dependabot.yml)) opens PRs for image tags in the compose
  files and Dockerfiles, the Python packages in `tools/requirements.txt` and the Actions.
- **Images** ([publish-images.yml](.github/workflows/publish-images.yml)) for WebVOWL,
  OpenRefine, the toolbox, Ontop, pySHACL, SHACL Play, pyLODE, sparql-mcp and the GraphRAG MCP are pushed to
  `ghcr.io/metacoding-io/semantic-stack-*` so `docker compose pull` works for everyone.
- **Tool selection** follows the October 2026 survey in [`reports/`](reports/), with its source
  notes in `research_notes/`.

---

## 🧭 Roadmap

- [ ] **Make the GHCR packages public** (`semantic-stack-webvowl`, `-openrefine`, `-tools`, `-ontop`, and the
      newer ones) so `docker compose pull` works for people outside the repository. CI logs in with its
      own token, so it does not notice.
- [ ] **Click through the landing page by hand** after `make up && make load`: CI proves every service
      answers, not that every page looks right.
- [ ] **Screenshots of the default stack and each profile**: the `screenshots` workflow produces them
      as an artifact; next step is to review a run and commit the keepers into the README.

---

## 🔗 Related

- [SemanticSeams](https://github.com/MetaCoding-io/SemanticSeams), a zoomable, multi-notation
  application graph over RDF; this stack is its development environment.
- [MetaCoding](https://metacoding.io), the data-centric consultancy behind both.

## 📄 License

[Apache-2.0](LICENSE) for the compose files, scripts and documentation in this repository. The
bundled services, their images and the submodule carry their own licenses.
