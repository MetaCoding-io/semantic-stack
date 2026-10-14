# 🧱 semantic-stack

[![smoke](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/smoke.yml/badge.svg)](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/smoke.yml)
[![publish-images](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/publish-images.yml/badge.svg)](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/publish-images.yml)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Docker Compose](https://img.shields.io/badge/docker-compose-2496ED?logo=docker&logoColor=white)](compose.yml)

**A turnkey semantic web / knowledge graph stack in one `docker compose up`.**
Triple stores, a caching SPARQL proxy, a Linked Data frontend, ontology visualisation, a visual
query builder, a SKOS vocabulary browser, data transformation, federated querying, SHACL
validation and schema-first modelling, each on its own port, with sample data and a smoke test
that proves every service answers.

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
- [🗂️ Repository layout](#️-repository-layout)
- [⚠️ Known limitations](#️-known-limitations)
- [🔁 Keeping it fresh](#-keeping-it-fresh)

---

## 🚀 Quick start

```bash
git clone https://github.com/MetaCoding-io/semantic-stack.git && cd semantic-stack
make qlever-index   # one-time: download the Olympics demo (~13 MB) and build the QLever index
make up             # start everything (first run builds WebVOWL, OpenRefine, SHACL Play and pySHACL, several minutes)
make load           # load data/sample into Fuseki
make smoke          # every service answers?
```

Then open the **landing page** at <http://localhost:8080>. It links every service and shows a
green dot next to the ones your browser can reach.

> 💡 No `make`? Every target is a one-liner; `make help` prints them.
> `docker compose pull webvowl openrefine shacl-play pyshacl` fetches the prebuilt images instead of building.

---

## 🎛️ Choose your stack

The stack is one `compose.yml` plus a few switches. Pick a **primary store**, then add
**profiles** for the extras you want. Everything not listed under a profile is always on.

### 🥇 Default: QLever as primary store

```bash
make qlever-index && make up
```

| Pick this when | You get |
|---|---|
| You want speed on large, read-mostly graphs and a realistic demo dataset | QLever + QLever UI serving the Olympics data (1.8M triples), Fuseki for writes, Trifid/Blueprint/Comunica/sparql-proxy pointed at QLever |

QLever is indexed once, not updated live. Point `qlever/Qleverfile` at your own files to index them instead.

### 🦀 Variant: Oxigraph as primary store

```bash
make oxigraph-up          # docker compose -f compose.yml -f compose.oxigraph.yml up -d
make load                 # loads data/sample into Fuseki *and* Oxigraph
```

| Pick this when | You get |
|---|---|
| You want zero setup and SPARQL Update on the primary store | Oxigraph (Rust, with a built-in YASGUI at :7878) replaces QLever; Trifid, Blueprint, Comunica and sparql-proxy follow; `data/sample` becomes dereferenceable at <http://localhost:8084/service/fuseki> |

### 🪶 Variant: Fuseki only

```bash
make fuseki-up            # docker compose -f compose.yml -f compose.fuseki.yml up -d
make load
```

| Pick this when | You get |
|---|---|
| You want the smallest footprint, or you need SHACL and a text index on the primary store | No QLever; everything points at Fuseki |

> Put `COMPOSE_FILE=compose.yml:compose.oxigraph.yml` in `.env` to make a variant the default for
> plain `docker compose` commands.

### ➕ Profiles

Profiles add services to **any** of the three choices above.

| Profile | Command | Adds |
|---|---|---|
| 🏗️ `setup` | `make qlever-index` | One-shot job that downloads the demo data and builds the QLever index |
| 🧰 `tools` | `make tools` | Shell in the Python toolbox (rdflib, pySHACL, OWL-RL, SPARQLWrapper, LinkML, pyLODE, pandas, jelly-cli) plus the RMLMapper, YARRRML, SDM-RDFizer, rudof and EYE CLIs, all with `./data` mounted at `/data` |
| 📓 `jupyter` | `make jupyter-up` | JupyterLab on <http://localhost:8888> with the same toolbox and `notebooks/01-hello-stack.ipynb` |
| 🪞 `ontop` | `make ontop-up` | Postgres seeded from `ontop/postgres/init.sql` + Ontop virtual knowledge graph on <http://localhost:8089> (SPARQL over SQL, no copying) |
| 🏢 `graphdb` | `make graphdb-up` | Ontotext GraphDB Free on <http://localhost:7200> |

<details>
<summary>Which services run in which choice?</summary>

| Service | Default | Oxigraph variant | Fuseki variant | Profile |
|---|:-:|:-:|:-:|---|
| Landing page, Fuseki, RDF4J, OpenRefine, WebVOWL, Trifid, Blueprint, Comunica | ✅ | ✅ | ✅ | always |
| sparql-proxy, Sparklis, Skosmos, SPARQL Anything, SHACL Play, pySHACL service | ✅ | ✅ | ✅ | always |
| QLever, QLever UI | ✅ | – | – | |
| Oxigraph | – | ✅ | – | |
| RMLMapper, YARRRML, SDM-RDFizer, rudof, EYE, Python toolbox | | | | `tools` |
| JupyterLab | | | | `jupyter` |
| Postgres, Ontop | | | | `ontop` |
| GraphDB | | | | `graphdb` |

</details>

<details>
<summary>Which store does each tool talk to?</summary>

Most services follow the **primary store** (QLever, Oxigraph or Fuseki, chosen above). A few
are deliberately pinned to Fuseki because it is the one store that is always on and writable, and
the file-based tools do not need a store at all. Every tool here speaks plain SPARQL 1.1, so
pointing one at GraphDB (`http://graphdb:7200/repositories/<repo>`) or Ontop
(`http://ontop:8080/sparql`) is a one-line change in `compose.yml` or the tool's config.

| Tool | Default (QLever) | Oxigraph variant | Fuseki variant | How it is wired |
|---|---|---|---|---|
| Trifid, Blueprint, Comunica | primary | primary | primary | override files set the endpoint |
| sparql-proxy | QLever | Oxigraph | Fuseki | override files set `SPARQL_BACKEND` |
| Sparklis | via sparql-proxy | via sparql-proxy | via sparql-proxy | browser app; the landing-page link passes `?endpoint=`, so any CORS-enabled endpoint works |
| Skosmos | Fuseki `ds` | Fuseki `ds` | Fuseki `ds` | `skosmos/config.ttl`; the sample thesaurus is loaded into Fuseki by `make load` (QLever is read-only, so it never holds it) |
| RDF4J Workbench | any | any | any | add a "SPARQL endpoint proxy" repository by container URL |
| SHACL Play, pySHACL service | none | none | none | upload files or paste text; SHACL Play's *Generate* page can read any endpoint by container URL |
| SPARQL Anything | files in `/data` | same | same | `SERVICE <x-sparql-anything:...>`; can federate to any endpoint with a second `SERVICE` |
| RMLMapper, SDM-RDFizer, rudof, EYE, jelly-cli, toolbox | files in `/data` | same | same | load the output with `scripts/load.sh`; `rudof` and the toolbox can also query endpoints directly |

</details>

---

## 🧩 Services by category

### 🗄️ Triple stores

| Service | URL | Notes |
|---|---|---|
| **QLever** | <http://localhost:7001> | Default primary. Very fast, read-mostly, indexed once. API only; use the QLever UI. |
| **Apache Jena Fuseki** | <http://localhost:3030> | Always on. SPARQL 1.1/1.2 Query + Update, Graph Store Protocol, SHACL endpoint, text index. Login `admin` / `admin`. |
| **Oxigraph** | <http://localhost:7878> | Variant primary. Rust, zero setup, built-in YASGUI. |
| **GraphDB** | <http://localhost:7200> | Profile `graphdb`. Ontotext GraphDB Free. |

### 🔍 Query and federate

| Service | URL | Notes |
|---|---|---|
| **QLever UI** | <http://localhost:7000> | Query editor with autocompletion, preconfigured for the QLever above. |
| **Trifid SPARQL console** | <http://localhost:8084/sparql> | YASGUI against the primary store, via Trifid's CORS-friendly `/query` proxy. |
| **Comunica** | <http://localhost:8087/sparql> | One federated SPARQL endpoint over every store in the stack. |
| **sparql-proxy** | <http://localhost:8090/sparql> | Caching, job-queueing, update-rejecting proxy in front of the primary store; dashboard at `/admin` (`admin` / `admin`). The endpoint to hand to browser tools and read-only users. |
| **Sparklis** | <http://localhost:8092> | Visual query builder: compose SPARQL by clicking through the data in plain English. The landing page opens it on sparql-proxy. |
| **RDF4J Workbench** | <http://localhost:8082/rdf4j-workbench/> | Repository manager; add any store as a "SPARQL endpoint proxy". |
| **Ontop** | <http://localhost:8089/sparql> | Profile `ontop`. SPARQL over a relational database. |

### 🧭 Browse and visualise

| Service | URL | Notes |
|---|---|---|
| **Landing page** | <http://localhost:8080> | Every service with a live reachability check. |
| **Trifid** | <http://localhost:8084> | Linked Data frontend: dereferenceable IRIs, Graph Explorer at `/graph-explorer`. |
| **Blueprint** | <http://localhost:8085> | Knowledge graph browser (needs a Blueprint configuration graph, see limitations). |
| **WebVOWL** | <http://localhost:8083> | OWL ontology visualisation with the OWL2VOWL converter. Try `data/sample/semantic-stack-vocab.ttl`. |
| **Skosmos** | <http://localhost:9090> | SKOS vocabulary browser and REST API over Fuseki. Shows `data/sample/semantic-stack-skos.ttl` after `make load`; add your own vocabularies in `skosmos/config.ttl`. |

### 🔄 Transform and map

| Service | How | Notes |
|---|---|---|
| **OpenRefine** | <http://localhost:3333> | Interactive data cleaning; `./data` is mounted read-only at `/import`. |
| **RMLMapper** | `docker compose --profile tools run --rm rmlmapper …` | CSV/JSON/XML → RDF with RML or R2RML. |
| **YARRRML parser** | `docker compose --profile tools run --rm yarrrml …` | Human-friendly YAML → RML. Walkthrough in [data/rml/README.md](data/rml/README.md). |
| **SDM-RDFizer** | `docker compose --profile tools run --rm sdm-rdfizer` | Second RML engine (100 % on every module of the new RML spec in the 2026 KGCW challenge); runs the same mapping via `data/rml/sdm-rdfizer.ini`. |
| **SPARQL Anything** | <http://localhost:8093/sparql> | Query CSV, JSON, XML, HTML, spreadsheets, … as RDF with no mapping (Facade-X). Endpoint `/sparql.anything`; try `data/queries/30-sparql-anything-csv.rq`. |
| **Ontop** | profile `ontop` | Keep the data in SQL, query it as RDF. |

### 🧪 Validate, model, document

| Tool | How | Notes |
|---|---|---|
| **pySHACL** | `docker compose --profile tools run --rm tools pyshacl -s sample/shapes.ttl sample/semantic-stack.ttl` | Also as an HTTP service at <http://localhost:8099/docs/swagger> (`POST /validate` with `data_graph` and `shapes_graph`) and as Fuseki's `/ds/shacl` endpoint. |
| **SHACL Play** | <http://localhost:8091> | Validate with readable reports, document shapes as HTML and UML, generate shapes from data, OWL → SHACL, SHACL rules. |
| **rudof** | `… rudof shacl-validate --shapes sample/shapes.ttl sample/semantic-stack.ttl` | ShEx + SHACL + DCTAP validation and conversion in one binary. `make validate` runs pySHACL and rudof. |
| **EYE** | `… eye --quiet --nope n3/socrates.n3 --pass` | Notation3 reasoner; `data/n3/socrates.n3` is the classic example. |
| **jelly-cli** | `… tools sh -c 'jelly-cli rdf to-jelly sample/semantic-stack.ttl > out/semantic-stack.jelly'` | Jelly binary RDF streaming, readable by Jena, RDF4J, Morph-KGC and TopQuadrant SHACL. |
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
| QLever | `http://qlever:7001` | `http://localhost:7001` | read-only, re-index instead |
| Fuseki | `http://fuseki:3030/ds/sparql` | `http://localhost:3030/ds/sparql` | `/ds/update`, `/ds/data` |
| Oxigraph | `http://oxigraph:7878/query` | `http://localhost:7878/query` | `/update`, `/store` |
| Comunica | `http://comunica:8080/sparql` | `http://localhost:8087/sparql` | no |
| Trifid proxy | `http://trifid:8080/query` | `http://localhost:8084/query` | no |
| sparql-proxy | `http://sparql-proxy:3000/sparql` | `http://localhost:8090/sparql` | rejected by design |
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
| **Fuseki, Oxigraph** | `./scripts/load.sh my-file.ttl` posts to a named graph over the Graph Store Protocol. Or use the Fuseki UI (upload) and Oxigraph's YASGUI (`INSERT DATA`). |
| **QLever** | Copy your `.ttl`/`.nt` into `./qlever/`, edit `qlever/Qleverfile` (`NAME`, `INPUT_FILES`, drop `GET_DATA_CMD`), then `make qlever-index` and `docker compose restart qlever qlever-ui`. |
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

Copy `.env.example` to `.env` to change ports, the Fuseki admin password, the sparql-proxy
admin password or the Postgres password. Every value has a default inside `compose.yml`, so
`.env` is optional.

On Linux, QLever writes its index into `./qlever` as `QLEVER_UID:QLEVER_GID` (default `1000:1000`).
`make` fills these from `id -u` / `id -g` automatically; when calling `docker compose` directly with
another uid, set them in `.env`.

`examples/compose.external-network.yml` shows how to attach the stores to a network owned by
another compose project (for example a monorepo whose services need `http://fuseki:3030`).

---

## 🗂️ Repository layout

```text
.
├── compose.yml                  # the stack: always-on services + profiles (setup, tools, jupyter, ontop, graphdb)
├── compose.oxigraph.yml         # override: Oxigraph as primary store
├── compose.fuseki.yml           # override: Fuseki as primary store
├── Makefile                     # make help
├── .env.example                 # ports, passwords, QLever uid/gid, COMPOSE_FILE
│
├── data/                        # mounted at /data in most containers; drop your files here
│   ├── sample/
│   │   ├── semantic-stack.ttl           # demo dataset: the stack describing itself
│   │   ├── semantic-stack-vocab.ttl     # its vocabulary (WebVOWL, pyLODE, Ontop ontology)
│   │   ├── semantic-stack-skos.ttl      # the tool categories as a SKOS thesaurus (Skosmos)
│   │   └── shapes.ttl                   # SHACL shapes for the demo data
│   ├── queries/                 # 01-03 sample data · 10-11 Olympics (QLever) · 20 federated · 30 SPARQL Anything
│   ├── rml/                     # services.csv + YARRRML mapping + SDM-RDFizer config, with README
│   ├── n3/socrates.n3           # Notation3 rules for EYE
│   ├── linkml/semantic-stack.yaml       # same model as a LinkML schema
│   └── out/                     # generated files (git-ignored)
│
├── scripts/
│   ├── load.sh                  # load data/sample into Fuseki (and Oxigraph when running)
│   └── smoke.sh                 # every service answers? used by CI and `make smoke`
│
├── landing/index.html           # landing page with live reachability dots
├── qlever/Qleverfile            # QLever dataset config (Olympics demo, port 7001)
├── qlever-ui/configure-and-run.sh   # points the QLever UI at this server on start
│
├── openrefine/Dockerfile        # OpenRefine from the official release tarball
├── webvowl/Dockerfile           # WebVOWL + OWL2VOWL built from upstream source
├── shacl-play/Dockerfile        # SHACL Play built from upstream source at a pinned release
├── pyshacl/Dockerfile           # pySHACL HTTP service from the pinned PyPI release
├── skosmos/config.ttl           # Skosmos endpoint + vocabulary configuration
├── tools/                       # Python toolbox image (+ jelly-cli): Dockerfile, requirements.in, requirements.txt
├── ontop/                       # Dockerfile (adds the Postgres JDBC driver), input/ mapping, postgres/ seed
├── notebooks/01-hello-stack.ipynb   # JupyterLab starter
│
├── examples/compose.external-network.yml   # join another compose project's network
├── reports/, research_notes/    # the October 2026 tool survey this selection is based on
├── .devcontainer/devcontainer.json         # VS Code dev container on the toolbox image
└── .github/
    ├── workflows/smoke.yml      # brings the stack up for real on every PR and weekly
    ├── workflows/publish-images.yml   # pushes the locally built images to GHCR
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
- **QLever** publishes no release tags, only `latest` and per-commit tags, so the stack pins a
  commit tag. Dependabot will not bump it; do so by hand. The same goes for **sparql-proxy**
  (pinned to a `snapshot-*` tag) and **Sparklis** (pinned by digest; its only image dates from
  January 2023, older than the current source).
- **Sparklis, rudof, EYE and SDM-RDFizer** ship amd64 images only; on Apple Silicon they run under
  emulation (`platform: linux/amd64` is set).
- **SPARQL Anything** is pinned to the 1.2.0 release. 1.3.0 (release candidates since October 2026)
  renames `fx:root` to `fx:Root` and moves engine options to the `fxe:` namespace; bump when it is final.
- **Skosmos** uses the plain-SPARQL `Generic` dialect against Fuseki's `ds` dataset, so search is
  regex-based. For large vocabularies create a dedicated Fuseki dataset with a jena-text index over
  the SKOS label properties and switch `skosmos/config.ttl` to the `JenaText` dialect.
- **Default credentials** (`admin`/`admin`, `stack`/`stack`) are for local use. Change them in
  `.env` before exposing any port.

---

## 🔁 Keeping it fresh

- **CI** ([smoke.yml](.github/workflows/smoke.yml)) brings up the default stack with a real QLever
  index, the Oxigraph variant, the Ontop profile and the tools image on every PR and weekly, and
  fails if any service stops answering.
- **Dependabot** ([dependabot.yml](.github/dependabot.yml)) opens PRs for image tags in the compose
  files and Dockerfiles, the Python packages in `tools/requirements.txt` and the Actions.
- **Images** ([publish-images.yml](.github/workflows/publish-images.yml)) for WebVOWL,
  OpenRefine, the toolbox, Ontop, pySHACL and SHACL Play are pushed to
  `ghcr.io/metacoding-io/semantic-stack-*` so `docker compose pull` works for everyone.
- **Tool selection** follows the October 2026 survey in [`reports/`](reports/), with its source
  notes in `research_notes/`.

---

## 🔗 Related

- [SemanticSeams](https://github.com/MetaCoding-io/SemanticSeams), a zoomable, multi-notation
  application graph over RDF; this stack is its development environment.
- [MetaCoding](https://metacoding.io), the data-centric consultancy behind both.

## 📄 License

[Apache-2.0](LICENSE) for the compose files, scripts and documentation in this repository. The
bundled services, their images and the submodule carry their own licenses.
