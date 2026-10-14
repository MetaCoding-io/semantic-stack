# 🧱 semantic-stack

[![smoke](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/smoke.yml/badge.svg)](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/smoke.yml)
[![publish-images](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/publish-images.yml/badge.svg)](https://github.com/MetaCoding-io/semantic-stack/actions/workflows/publish-images.yml)
[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Docker Compose](https://img.shields.io/badge/docker-compose-2496ED?logo=docker&logoColor=white)](compose.yml)

**A turnkey semantic web / knowledge graph stack in one `docker compose up`.**
Apache Jena Fuseki as the store, a Linked Data frontend, ontology visualisation, data
transformation, federated querying, SHACL validation and schema-first modelling, each on its own
port, with sample data and a smoke test that proves every service answers. Extra engines (QLever,
Oxigraph, GraphDB) and tools are one profile away.

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
make up      # start the stack (first run builds WebVOWL and OpenRefine, a few minutes)
make load    # load data/sample into Fuseki
make smoke   # every service answers?
```

Then open the **landing page** at <http://localhost:8080>. It links every service and shows a
green dot next to the ones your browser can reach. Try a query in the
[SPARQL console](http://localhost:8084/sparql), or dereference
<http://localhost:8084/service/fuseki> to see Linked Data working end to end.

> 💡 No `make`? Every target is a one-liner; `make help` prints them.
> `docker compose pull webvowl openrefine` fetches the prebuilt images instead of building.

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
| 🧰 `tools` | `make tools` | Shell in the **Python toolbox** (rdflib, pySHACL, OWL-RL, SPARQLWrapper, LinkML, pyLODE, pandas) plus the **RMLMapper** and **YARRRML** CLIs, `./data` mounted at `/data` | You want to validate, convert, model or script |
| 📓 `jupyter` | `make jupyter-up` | **JupyterLab** with the same toolbox and `notebooks/01-hello-stack.ipynb` | You prefer notebooks |
| 🪞 `ontop` | `make ontop-up` | **Postgres** (seeded demo tables) + **Ontop** virtual knowledge graph: SPARQL over SQL, nothing copied | You have relational data and want it as RDF without an ETL |

Profiles combine freely (`docker compose --profile qlever --profile oxigraph up -d`). Put
`COMPOSE_PROFILES=qlever,oxigraph` in `.env` to make them part of your default `make up`.

<details>
<summary>Pointing Trifid, Blueprint or Comunica at another store</summary>

All three follow Fuseki by default. Three variables in `.env` move them:

```bash
TRIFID_SPARQL_ENDPOINT_URL=http://qlever:7001          # Trifid (and Blueprint through its proxy)
TRIFID_DATASET_BASE_URL=http://wallscope.co.uk/        # base of the IRIs in that store (Olympics data)
BLUEPRINT_FTS_DIALECT=qlever                           # fuseki | qlever | stardog | graphdb | neptune
COMUNICA_SOURCES="sparql@http://fuseki:3030/ds/sparql sparql@http://qlever:7001"   # space-separated
```

Comunica fails a federated query if any listed source is down, so only list stores whose profile is up.

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

### 🔍 Query and federate

| Service | URL | Notes |
|---|---|---|
| **Trifid SPARQL console** | <http://localhost:8084/sparql> | YASGUI against Fuseki, via Trifid's CORS-friendly `/query` proxy. |
| **Comunica** | <http://localhost:8087/sparql> | One federated SPARQL endpoint; Fuseki by default, add other stores with `COMUNICA_SOURCES`. |
| **QLever UI** | <http://localhost:7000> | Profile `qlever`. Query editor with autocompletion, preconfigured for the QLever above. |
| **RDF4J Workbench** | <http://localhost:8082/rdf4j-workbench/> | Repository manager; add any store as a "SPARQL endpoint proxy". |
| **Ontop** | <http://localhost:8089/sparql> | Profile `ontop`. SPARQL over a relational database. |

### 🧭 Browse and visualise

| Service | URL | Notes |
|---|---|---|
| **Landing page** | <http://localhost:8080> | Every service with a live reachability check. |
| **Trifid** | <http://localhost:8084> | Linked Data frontend over Fuseki: dereferenceable IRIs (<http://localhost:8084/service/fuseki> after `make load`), Graph Explorer at `/graph-explorer`. |
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
| Fuseki | `http://fuseki:3030/ds/sparql` | `http://localhost:3030/ds/sparql` | `/ds/update`, `/ds/data` |
| QLever (profile) | `http://qlever:7001` | `http://localhost:7001` | re-index (`make qlever-index`) |
| Oxigraph (profile) | `http://oxigraph:7878/query` | `http://localhost:7878/query` | `/update`, `/store` |
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
| **Fuseki** (and Oxigraph when up) | `./scripts/load.sh my-file.ttl` posts to a named graph over the Graph Store Protocol. Or use the Fuseki UI (upload), `/ds/update`, or Oxigraph's YASGUI. |
| **QLever** | Copy your `.ttl`/`.nt` into `./qlever/`, edit `qlever/Qleverfile` (`NAME`, `INPUT_FILES`, drop `GET_DATA_CMD`), then `make qlever-index` and `docker compose --profile qlever restart qlever qlever-ui`. |
| **From CSV/JSON/XML** | Write a YARRRML mapping, run `yarrrml` then `rmlmapper` ([data/rml/README.md](data/rml/README.md)), load the output. |
| **From a SQL database** | Point the `ontop` profile at it: edit `ontop/input/mapping.obda` and the `ONTOP_DB_*` variables. Nothing gets copied. |
| **Validate first** | pySHACL from the toolbox, or POST shapes to Fuseki's `/ds/shacl`. |

> ℹ️ Fuseki's `ds` dataset treats the default graph as the union of all named graphs, so load into
> a named graph (the script does) rather than the default graph.

Sample data, example queries, RML and LinkML examples live in [`data/`](data/README.md).

---

## ⚙️ Configuration

Copy `.env.example` to `.env` to change ports, passwords, default profiles (`COMPOSE_PROFILES`)
or which store Trifid and Comunica use. Every value has a default inside `compose.yml`, so `.env`
is optional.

On Linux, QLever writes its index into `./qlever` as `QLEVER_UID:QLEVER_GID` (default `1000:1000`).
`make` fills these from `id -u` / `id -g` automatically; when calling `docker compose` directly with
another uid, set them in `.env`.

`examples/compose.external-network.yml` shows how to attach the stores to a network owned by
another compose project (for example a monorepo whose services need `http://fuseki:3030`).

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
├── qlever/Qleverfile            # QLever dataset config for the qlever profile (Olympics demo, port 7001)
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
    ├── workflows/smoke.yml      # default stack + one job per profile, on every PR and weekly
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
- **QLever** (profile) publishes no release tags, only `latest` and per-commit tags, so the stack
  pins a commit tag. Dependabot will not bump it; do so by hand. Its SPARQL Update support needs
  an access token and lives on top of the prebuilt index, which is why it is not the default.
- **Default credentials** (`admin`/`admin`, `stack`/`stack`) are for local use. Change them in
  `.env` before exposing any port.

---

## 🔁 Keeping it fresh

- **CI** ([smoke.yml](.github/workflows/smoke.yml)) brings up the default stack and, in parallel,
  the QLever (with a real index), Oxigraph and Ontop profiles and the tools image on every PR and
  weekly, and fails if any service stops answering. It pulls the published images and rebuilds one
  only when its Dockerfile changed, so a run takes about two minutes.
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
