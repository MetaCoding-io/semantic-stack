# semantic-stack

A turnkey semantic web / knowledge graph stack in one `docker compose`. Two SPARQL stores, a
caching SPARQL proxy, a Linked Data frontend, ontology visualisation, a visual query builder, a
SKOS vocabulary browser, data transformation, federated querying, SHACL validation and
schema-first modelling, each on its own port, with sample data and a smoke test.

A [MetaCoding](https://metacoding.io) project: the local stack behind our data-centric consulting
work and the environment [SemanticSeams](https://github.com/MetaCoding-io/SemanticSeams) is
developed against.

## Quick start

```bash
git clone https://github.com/MetaCoding-io/semantic-stack.git && cd semantic-stack
make qlever-index   # one-time: download the Olympics demo data (~13 MB) and build the QLever index
make up             # start everything (first run builds WebVOWL, OpenRefine, SHACL Play and pySHACL, several minutes)
make load           # load data/sample into Fuseki
make smoke          # every service answers?
```

Then open the landing page at <http://localhost:8080>. It links every service and shows which
ones are reachable.

No `make`? The targets are one-liners; `make help` prints them. `docker compose pull webvowl openrefine shacl-play pyshacl`
fetches prebuilt images instead of building.

## What you get

| Service | URL | What it is for |
|---|---|---|
| Landing page | <http://localhost:8080> | Links and live reachability for everything below |
| **QLever** | <http://localhost:7001> | Primary store of the default stack. Very fast, read-mostly, indexed once. Holds the Olympics demo (1.8M triples). API only. |
| QLever UI | <http://localhost:7000> | Query editor with autocompletion, preconfigured for the QLever above |
| **Apache Jena Fuseki** | <http://localhost:3030> | General-purpose store: SPARQL 1.1/1.2 Query and Update, Graph Store Protocol, SHACL endpoint, text index. Login `admin`/`admin`. |
| Trifid | <http://localhost:8084> | Linked Data frontend over the primary store: dereferenceable IRIs, YASGUI console at `/sparql`, Graph Explorer, CORS proxy at `/query` |
| Blueprint | <http://localhost:8085> | Knowledge graph browser (needs a Blueprint configuration graph, see below) |
| WebVOWL | <http://localhost:8083> | OWL ontology visualisation with the OWL2VOWL converter |
| RDF4J Workbench | <http://localhost:8082/rdf4j-workbench/> | Repository manager; proxy any store with a "SPARQL endpoint proxy" repository |
| Comunica | <http://localhost:8087/sparql> | Federated SPARQL endpoint over every store in the stack |
| sparql-proxy | <http://localhost:8090/sparql> | Caching, job-queueing, update-rejecting proxy in front of the primary store; admin dashboard at `/admin` (`admin`/`admin`). The endpoint to give browser tools and read-only users. |
| Sparklis | <http://localhost:8092> | Visual query builder: compose SPARQL by clicking through the data in plain English. Works against any CORS-enabled endpoint; the landing page opens it on sparql-proxy. |
| Skosmos | <http://localhost:9090> | SKOS vocabulary browser and REST API over Fuseki. Shows `data/sample/semantic-stack-skos.ttl` after `make load`; add your own vocabularies in `skosmos/config.ttl`. |
| OpenRefine | <http://localhost:3333> | Interactive data cleaning; `./data` mounted read-only at `/import` |
| SPARQL Anything | <http://localhost:8093/sparql> | Query CSV, JSON, XML, HTML, spreadsheets, ... as RDF with no mapping (Facade-X). Endpoint `/sparql.anything`, `./data` visible as `/data`. |
| SHACL Play | <http://localhost:8091> | Validate with readable reports, document shapes as HTML and UML, generate shapes from data, OWL to SHACL, SHACL rules |
| pySHACL service | <http://localhost:8099/docs/swagger> | SHACL validation over HTTP: `POST /validate` with `data_graph` and `shapes_graph` |
| RMLMapper, YARRRML, SDM-RDFizer | CLI (`--profile tools`) | CSV/JSON/XML to RDF with two RML engines, see [data/rml/README.md](data/rml/README.md) |
| rudof | CLI (`--profile tools`) | ShEx + SHACL + DCTAP validation and conversion: `run --rm rudof shacl-validate --shapes sample/shapes.ttl sample/semantic-stack.ttl` |
| EYE | CLI (`--profile tools`) | Notation3 reasoner: `run --rm eye --quiet --nope n3/socrates.n3 --pass` |
| Python toolbox | CLI (`--profile tools`) | rdflib, pySHACL, OWL-RL, SPARQLWrapper, LinkML, pyLODE, pandas, plus `jelly-cli` for Jelly binary RDF streams |
| JupyterLab | <http://localhost:8888> (`--profile jupyter`) | Same toolbox as notebooks; `notebooks/01-hello-stack.ipynb` to start |
| Oxigraph | <http://localhost:7878> (`compose.oxigraph.yml`) | Alternative primary store: Rust, zero setup, SPARQL Update |
| Ontop + Postgres | <http://localhost:8089> (`--profile ontop`) | Virtual knowledge graph: SPARQL over a relational database |
| GraphDB | <http://localhost:7200> (`--profile graphdb`) | Ontotext GraphDB, Free edition |

Every image is pinned. Fuseki 6.2 (Jena 6), RDF4J 6.1, Oxigraph 0.5 and Comunica 5 support
RDF 1.2 and SPARQL 1.2.

### SPARQL endpoints

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

**Browser URLs versus container URLs.** Services talk to each other by service name
(`http://fuseki:3030/...`). Anything that runs in your browser (Blueprint, the QLever UI's
backend setting, YASGUI) must use `localhost` and the host port. Getting this wrong is the usual
reason a service "starts but shows nothing".

## Variants

The default stack uses QLever as the primary store. Two override files swap it:

```bash
make oxigraph-up   # docker compose -f compose.yml -f compose.oxigraph.yml up -d
make fuseki-up     # docker compose -f compose.yml -f compose.fuseki.yml up -d
```

Both skip the indexing step, point Trifid, Blueprint, Comunica and sparql-proxy at the new primary store and
make `data/sample` dereferenceable through Trifid (its IRIs live under `http://localhost:8084/`,
so <http://localhost:8084/service/fuseki> resolves). Put `COMPOSE_FILE=compose.yml:compose.oxigraph.yml`
in `.env` to make a variant the default for plain `docker compose` commands.

Optional profiles add services to any variant:

```bash
make tools        # shell in the Python toolbox, ./data mounted at /data
make jupyter-up   # JupyterLab on :8888
make ontop-up     # Postgres seeded from ontop/postgres/init.sql + Ontop on :8089
make graphdb-up   # GraphDB on :7200
```

## Loading your own data

| Where | How |
|---|---|
| Fuseki, Oxigraph | `./scripts/load.sh my-file.ttl` posts to a named graph over the Graph Store Protocol. Or use the Fuseki UI (upload) and Oxigraph's YASGUI (`INSERT DATA`). |
| QLever | Copy your `.ttl`/`.nt` into `./qlever/`, edit `qlever/Qleverfile` (`NAME`, `INPUT_FILES`, drop `GET_DATA_CMD`), then `make qlever-index` and `docker compose restart qlever qlever-ui`. |
| From CSV/JSON/XML | Write a YARRRML mapping, run `yarrrml` then `rmlmapper` ([data/rml/README.md](data/rml/README.md)), load the output. |
| From a SQL database | Point the `ontop` profile at it: edit `ontop/input/mapping.obda` and the `ONTOP_DB_*` variables; no copying. |
| Validate first | `make validate` (pySHACL and rudof from the CLI), SHACL Play at <http://localhost:8091/validate>, `POST` to the pySHACL service at `:8099/validate`, or `POST` to Fuseki's `/ds/shacl`. |
| Skip the mapping | Query the file directly with SPARQL Anything: `data/queries/30-sparql-anything-csv.rq` reads `data/rml/services.csv` as RDF. |

Fuseki's `ds` dataset treats the default graph as the union of all named graphs, so load into a
named graph (the script does) rather than the default graph.

## Modelling and documentation

- **LinkML** (`data/linkml/semantic-stack.yaml`): write the model once in YAML, generate OWL,
  SHACL, JSON Schema or Pydantic with `gen-owl`, `gen-shacl`, `gen-json-schema`, `gen-pydantic`
  from the tools container.
- **pyLODE**: `docker compose --profile tools run --rm tools pylode sample/semantic-stack-vocab.ttl -o out/vocab.html`
  renders HTML documentation for an ontology.
- **WebVOWL**: paste an ontology IRI or upload `data/sample/semantic-stack-vocab.ttl` at <http://localhost:8083>.
- **SHACL Play** (<http://localhost:8091>): upload `data/sample/shapes.ttl` under *Documentation* for an HTML
  page with a UML diagram, or under *Generate* point it at a SPARQL endpoint to derive shapes from data.
- **Skosmos** (<http://localhost:9090>): `data/sample/semantic-stack-skos.ttl` is a small SKOS thesaurus of
  the tool categories. To publish your own vocabulary, load it into a named graph in Fuseki and add a
  `skosmos:Vocabulary` block to `skosmos/config.ttl` (the comments there explain each property).
- **EYE**: `data/n3/socrates.n3` shows Notation3 rules; `docker compose --profile tools run --rm eye --quiet --nope n3/socrates.n3 --pass`
  prints the derived triples.
- **Jelly**: `jelly-cli rdf to-jelly sample/semantic-stack.ttl > out/semantic-stack.jelly` in the tools
  container writes the binary streaming format that Morph-KGC, TopQuadrant SHACL, Jena and RDF4J can read.

## Configuration

Copy `.env.example` to `.env` to change ports, the Fuseki admin password, the sparql-proxy
admin password or the Postgres password. Every value has a default inside `compose.yml`, so
`.env` is optional.

On Linux, QLever writes its index into `./qlever` as `QLEVER_UID:QLEVER_GID` (default `1000:1000`).
`make` fills these from `id -u` / `id -g` automatically; when calling `docker compose` directly with
another uid, set them in `.env`.

`examples/compose.external-network.yml` shows how to attach the stores to a network owned by
another compose project (for example a monorepo whose services need `http://fuseki:3030`).

## Known limitations

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
- Default credentials (`admin`/`admin`, `stack`/`stack`) are for local use. Change them in `.env`
  before exposing any port.

## Keeping it fresh

- `.github/workflows/smoke.yml` brings up the default stack, the Oxigraph variant, the Ontop
  profile and the tools image on every push and weekly, and fails if any service stops answering.
- `.github/dependabot.yml` opens PRs for image tags in the compose files and Dockerfiles, the
  Python packages in `tools/requirements.txt` and the Actions.
- `.github/workflows/publish-images.yml` pushes the locally built images (WebVOWL, OpenRefine,
  tools, Ontop, pySHACL, SHACL Play) to `ghcr.io/metacoding-io/semantic-stack-*` so
  `docker compose pull` works for everyone.
- `reports/` holds the October 2026 survey of self-hostable semantic web tools that this
  selection is based on, with its source notes in `research_notes/`.

## Repository layout

```
compose.yml                 default stack            scripts/load.sh      load data/sample into the stores
compose.oxigraph.yml        Oxigraph variant         scripts/smoke.sh     check every service answers
compose.fuseki.yml          Fuseki-primary variant   landing/             landing page
qlever/Qleverfile           QLever dataset config    data/                sample data, queries, RML, LinkML
qlever-ui/                  QLever UI startup        notebooks/           JupyterLab examples
openrefine/ webvowl/        Dockerfiles for images   ontop/               Ontop mapping + Postgres seed
pyshacl/ shacl-play/        Dockerfiles for images   skosmos/config.ttl   Skosmos vocabularies
tools/                      Python toolbox image     examples/            optional compose overrides
reports/ research_notes/    tool survey behind the selection
```

`rdflib-orm` is a git submodule (`git submodule update --init`): an experimental Python ORM for
RDF by MetaCoding, kept here for convenience and not used by the stack itself.

## Related

- [SemanticSeams](https://github.com/MetaCoding-io/SemanticSeams), a zoomable, multi-notation
  application graph over RDF; this stack is its development environment.
- [MetaCoding](https://metacoding.io), the data-centric consultancy behind both.

## License

[Apache-2.0](LICENSE) for the compose files, scripts and documentation in this repository. The
bundled services, their images and the submodule carry their own licenses.
