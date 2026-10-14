# 🧱 semantic-stack

[![smoke](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/smoke.yml/badge.svg)](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/smoke.yml)
[![publish-images](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/publish-images.yml/badge.svg)](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/publish-images.yml)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Docker Compose](https://img.shields.io/badge/docker-compose-2496ED?logo=docker&logoColor=white)](compose.yml)

**A turnkey semantic web / knowledge graph stack in one `docker compose up`.**
Triple stores, a Linked Data frontend, ontology visualisation, data transformation, federated
querying, SHACL validation and schema-first modelling, each on its own port, with sample data and
a smoke test that proves every service answers.

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
make up             # start everything (first run builds WebVOWL and OpenRefine, a few minutes)
make load           # load data/sample into Fuseki
make smoke          # every service answers?
```

Then open the **landing page** at <http://localhost:8080>. It links every service and shows a
green dot next to the ones your browser can reach.

> 💡 No `make`? Every target is a one-liner; `make help` prints them.
> `docker compose pull webvowl openrefine` fetches the prebuilt images instead of building.

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
| You want speed on large, read-mostly graphs and a realistic demo dataset | QLever + QLever UI serving the Olympics data (1.8M triples), Fuseki for writes, Trifid/Blueprint/Comunica pointed at QLever |

QLever is indexed once, not updated live. Point `qlever/Qleverfile` at your own files to index them instead.

### 🦀 Variant: Oxigraph as primary store

```bash
make oxigraph-up          # docker compose -f compose.yml -f compose.oxigraph.yml up -d
make load                 # loads data/sample into Fuseki *and* Oxigraph
```

| Pick this when | You get |
|---|---|
| You want zero setup and SPARQL Update on the primary store | Oxigraph (Rust, with a built-in YASGUI at :7878) replaces QLever; Trifid, Blueprint and Comunica follow; `data/sample` becomes dereferenceable at <http://localhost:8084/service/fuseki> |

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
| 🧰 `tools` | `make tools` | Shell in the Python toolbox (rdflib, pySHACL, OWL-RL, SPARQLWrapper, LinkML, pyLODE, pandas) plus the RMLMapper and YARRRML CLIs, all with `./data` mounted at `/data` |
| 📓 `jupyter` | `make jupyter-up` | JupyterLab on <http://localhost:8888> with the same toolbox and `notebooks/01-hello-stack.ipynb` |
| 🪞 `ontop` | `make ontop-up` | Postgres seeded from `ontop/postgres/init.sql` + Ontop virtual knowledge graph on <http://localhost:8089> (SPARQL over SQL, no copying) |
| 🏢 `graphdb` | `make graphdb-up` | Ontotext GraphDB Free on <http://localhost:7200> |

<details>
<summary>Which services run in which choice?</summary>

| Service | Default | Oxigraph variant | Fuseki variant | Profile |
|---|:-:|:-:|:-:|---|
| Landing page, Fuseki, RDF4J, OpenRefine, WebVOWL, Trifid, Blueprint, Comunica | ✅ | ✅ | ✅ | always |
| QLever, QLever UI | ✅ | – | – | |
| Oxigraph | – | ✅ | – | |
| RMLMapper, YARRRML, Python toolbox | | | | `tools` |
| JupyterLab | | | | `jupyter` |
| Postgres, Ontop | | | | `ontop` |
| GraphDB | | | | `graphdb` |

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
| **RDF4J Workbench** | <http://localhost:8082/rdf4j-workbench/> | Repository manager; add any store as a "SPARQL endpoint proxy". |
| **Ontop** | <http://localhost:8089/sparql> | Profile `ontop`. SPARQL over a relational database. |

### 🧭 Browse and visualise

| Service | URL | Notes |
|---|---|---|
| **Landing page** | <http://localhost:8080> | Every service with a live reachability check. |
| **Trifid** | <http://localhost:8084> | Linked Data frontend: dereferenceable IRIs, Graph Explorer at `/graph-explorer`. |
| **Blueprint** | <http://localhost:8085> | Knowledge graph browser (needs a Blueprint configuration graph, see limitations). |
| **WebVOWL** | <http://localhost:8083> | OWL ontology visualisation with the OWL2VOWL converter. Try `data/sample/semantic-stack-vocab.ttl`. |

### 🔄 Transform and map

| Service | How | Notes |
|---|---|---|
| **OpenRefine** | <http://localhost:3333> | Interactive data cleaning; `./data` is mounted read-only at `/import`. |
| **RMLMapper** | `docker compose --profile tools run --rm rmlmapper …` | CSV/JSON/XML → RDF with RML or R2RML. |
| **YARRRML parser** | `docker compose --profile tools run --rm yarrrml …` | Human-friendly YAML → RML. Walkthrough in [data/rml/README.md](data/rml/README.md). |
| **Ontop** | profile `ontop` | Keep the data in SQL, query it as RDF. |

### 🧪 Validate, model, document

| Tool | How | Notes |
|---|---|---|
| **pySHACL** | `docker compose --profile tools run --rm tools pyshacl -s sample/shapes.ttl sample/semantic-stack.ttl` | Also available as Fuseki's `/ds/shacl` endpoint. |
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
| **Validate first** | pySHACL from the toolbox, or POST shapes to Fuseki's `/ds/shacl`. |

> ℹ️ Fuseki's `ds` dataset treats the default graph as the union of all named graphs, so load into
> a named graph (the script does) rather than the default graph.

Sample data, example queries, RML and LinkML examples live in [`data/`](data/README.md).

---

## ⚙️ Configuration

Copy `.env.example` to `.env` to change ports, the Fuseki admin password or the Postgres
password. Every value has a default inside `compose.yml`, so `.env` is optional.

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
│   │   └── shapes.ttl                   # SHACL shapes for the demo data
│   ├── queries/                 # 01-03 sample data · 10-11 Olympics (QLever) · 20 federated (Comunica)
│   ├── rml/                     # services.csv + YARRRML mapping, with README
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
├── tools/                       # Python toolbox image: Dockerfile, requirements.in, requirements.txt
├── ontop/                       # Dockerfile (adds the Postgres JDBC driver), input/ mapping, postgres/ seed
├── notebooks/01-hello-stack.ipynb   # JupyterLab starter
│
├── examples/compose.external-network.yml   # join another compose project's network
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
  commit tag. Dependabot will not bump it; do so by hand.
- **Default credentials** (`admin`/`admin`, `stack`/`stack`) are for local use. Change them in
  `.env` before exposing any port.

---

## 🔁 Keeping it fresh

- **CI** ([smoke.yml](.github/workflows/smoke.yml)) brings up the default stack with a real QLever
  index, the Oxigraph variant, the Ontop profile and the tools image on every PR and weekly, and
  fails if any service stops answering.
- **Dependabot** ([dependabot.yml](.github/dependabot.yml)) opens PRs for image tags in the compose
  files and Dockerfiles, the Python packages in `tools/requirements.txt` and the Actions.
- **Images** ([publish-images.yml](.github/workflows/publish-images.yml)) are pushed to
  `ghcr.io/metacoding-io/semantic-stack-*` so `docker compose pull` works for everyone.

---

## 🔗 Related

- [SemanticSeams](https://github.com/MetaCoding-io/SemanticSeams), a zoomable, multi-notation
  application graph over RDF; this stack is its development environment.
- [MetaCoding](https://metacoding.io), the data-centric consultancy behind both.

## 📄 License

[Apache-2.0](LICENSE) for the compose files, scripts and documentation in this repository. The
bundled services, their images and the submodule carry their own licenses.
