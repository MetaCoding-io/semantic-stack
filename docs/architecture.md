# 🏗️ Architecture

How the pieces fit, and which of them you can swap. The diagrams render on GitHub; the tables carry
the details. Every URL is the compose default; ports are the ones in [`.env.example`](../.env.example).

Three rules explain most of the wiring:

1. **Everything speaks SPARQL 1.1 over HTTP, or works on files.** No tool is tied to an engine, but
   each is *configured* for one, and that default is Fuseki.
2. **Server-side tools use container names, browser-side apps use `localhost`.** Trifid, Comunica
   or Prez run inside the Compose network and reach `http://fuseki:3030`. Blueprint, Sparklis,
   Sparnatural, QLever UI and Prez UI are JavaScript that runs in *your* browser, so they can only
   reach host ports, which is why they go through Trifid's `/query` or sparql-proxy instead of the
   store directly.
3. **Stores do not share data.** `make load` fills every writable store that is running with the
   same sample dataset; QLever serves the Olympics index and Ontop a SQL demo, so pointing a tool
   at them changes what it shows, not just where it reads.

---

## The default stack: everything around Fuseki

`make up && make load`. One store, one dataset (`ds`), every other container either reads it,
fronts it, or works on files.

```mermaid
flowchart LR
  you([Your browser])
  landing["Landing page · :8080"]

  subgraph browse ["Query and browse"]
    direction TB
    trifid["Trifid · :8084<br/>Linked Data pages · YASGUI · Graph Explorer · /query proxy"]
    blueprint["Blueprint · :8085<br/>knowledge-graph browser"]
    sparklis["Sparklis · :8092<br/>query by clicking"]
    sparnatural["Sparnatural · :8094<br/>visual query builder"]
    skosmos["Skosmos · :9090<br/>SKOS browser + REST"]
    rdf4j["RDF4J Workbench · :8082<br/>repository manager"]
  end

  subgraph front ["Endpoints in front of the store"]
    direction TB
    proxy["sparql-proxy · :8090<br/>cache · job queue · rejects updates"]
    comunica["Comunica · :8087<br/>federated SPARQL"]
  end

  fuseki[("Apache Jena Fuseki · :3030<br/>dataset ds · SPARQL Query + Update · GSP · SHACL · text index")]

  subgraph files ["Work on files or uploads, not on the store"]
    direction TB
    openrefine["OpenRefine · :3333"]
    sa["SPARQL Anything · :8093<br/>CSV/JSON/XML as RDF"]
    shaclplay["SHACL Play · :8091"]
    pyshacl["pySHACL service · :8099"]
    webvowl["WebVOWL · :8083"]
  end

  data[("./data<br/>sample/ queries/ rml/ out/")]

  you --> landing
  landing -.->|links to everything| browse
  you --> browse
  blueprint -.->|browser calls| trifid
  sparklis -.->|browser calls| proxy
  sparnatural -.->|browser calls| proxy
  trifid --> fuseki
  skosmos --> fuseki
  proxy --> fuseki
  comunica --> fuseki
  rdf4j -.->|"'SPARQL endpoint proxy' repository, added by hand"| fuseki
  data ==>|make load| fuseki
  data --> openrefine
  data --> sa
  you -.->|uploads| shaclplay
  you -.->|uploads| pyshacl
  you -.->|uploads| webvowl

  classDef store fill:#fde68a,stroke:#b45309,color:#1c1917
  classDef browser fill:#dbeafe,stroke:#1d4ed8,color:#1c1917
  classDef standalone fill:#e5e7eb,stroke:#6b7280,color:#1c1917
  class fuseki store
  class blueprint,sparklis,sparnatural browser
  class openrefine,sa,shaclplay,pyshacl,webvowl standalone
```

Solid arrows are server-to-server calls inside the Compose network. Dotted arrows start in your
browser. Blue boxes are browser-side apps (rule 2 above); grey boxes never touch the store.

---

## Profiles: what plugs into Fuseki, what stands alone

`docker compose --profile <name> up -d`, or `make <name>-up`. Most profile services are more
readers of the same Fuseki; a few bring their own store or their own data.

```mermaid
flowchart LR
  fuseki[("Fuseki · :3030 · ds")]

  subgraph readers ["More readers of Fuseki"]
    direction TB
    prez["prez · Prez API :8000 + Prez UI :8001<br/>Linked Data API, content negotiation"]
    grlc["grlc · :8088<br/>REST routes from grlc/queries/*.rq"]
    rpt["rpt · RPT server :8642<br/>YASGUI · GraphQL · LD viewer"]
    gx["graph-explorer · :8095<br/>click-to-expand graph"]
    mcp["mcp · sparql-mcp :8103<br/>query · update · GSP for agents"]
    obs["observability · sparql-exporter :9199 → Prometheus :9091 → Grafana :3000"]
    nb["jupyter · JupyterLab :8888<br/>tools · Python toolbox + RML/rudof/EYE/ROBOT/Nemo/WIDOCO CLIs"]
  end

  subgraph writers ["Write into Fuseki"]
    direction TB
    graphrag["graphrag · Flexible GraphRAG :8104 + UI :8105 + MCP :3001<br/>documents → LLM → triples (own dataset flexible-graphrag)"]
    qdrant[("Qdrant · :6333<br/>vectors")]
    llm["Anthropic API, or the ollama profile :11434"]
    lpetl["lp-etl · LinkedPipes ETL :9080<br/>pipelines you draw; endpoint set per pipeline"]
  end

  subgraph stores ["Their own store (not Fuseki)"]
    direction TB
    oxigraph[("oxigraph · :7878<br/>sample data via make load")]
    qlever[("qlever · QLever :7001 + QLever UI :7000<br/>Olympics index, read-only")]
    graphdb[("graphdb · :7200<br/>empty until you create a repository")]
    virtuoso[("virtuoso · :8890<br/>sample data via make load")]
    geo[("geosparql · Fuseki + GeoSPARQL :3031<br/>sample data + WKT via make load")]
    ontop[("ontop · Ontop :8089 over Postgres<br/>SQL demo tables as a virtual graph, read-only")]
  end

  subgraph alone ["No store at all"]
    direction TB
    pylode["docs · pyLODE server :8096"]
    itb["validation · ITB SHACL validator :8097"]
    rudofmcp["mcp · rudof-mcp :8102 · open-ontologies :8101"]
    solid["solid · Community Solid Server :8100"]
  end

  prez --> fuseki
  grlc --> fuseki
  rpt --> fuseki
  gx --> fuseki
  mcp --> fuseki
  obs --> fuseki
  nb --> fuseki
  nb -.-> oxigraph
  nb -.-> qlever
  graphrag ==> fuseki
  graphrag --> qdrant
  graphrag --> llm
  lpetl ==>|SPARQL Update, if you tell it to| fuseki

  classDef store fill:#fde68a,stroke:#b45309,color:#1c1917
  classDef standalone fill:#e5e7eb,stroke:#6b7280,color:#1c1917
  class fuseki,oxigraph,qlever,graphdb,virtuoso,geo,ontop,qdrant store
  class pylode,itb,rudofmcp,solid standalone
```

The toolbox and JupyterLab know all three container URLs (`FUSEKI_URL`, `OXIGRAPH_URL`,
`QLEVER_URL`); the dotted arrows only work while those profiles are up.

---

## Alternatives: what you can point where

The store under each consumer is a setting, not a design decision. The hub in the middle is the
whole trick: every consumer takes a SPARQL endpoint URL, every store offers one.

```mermaid
flowchart LR
  subgraph consumers ["Consumers (what to change)"]
    direction TB
    c1["Trifid, and Blueprint through it<br/><code>TRIFID_SPARQL_ENDPOINT_URL</code>"]
    c2["sparql-proxy, and Sparklis + Sparnatural through it<br/><code>SPARQL_PROXY_BACKEND</code>"]
    c3["Comunica<br/><code>COMUNICA_SOURCES</code> (several at once)"]
    c4["Prez · grlc · RPT · Graph Explorer · sparql-mcp<br/><code>*_SPARQL_ENDPOINT</code>, <code>*_URL</code> in .env"]
    c5["Skosmos<br/><code>skosmos/config.ttl</code>"]
    c6["Grafana + sparql-exporter<br/><code>grafana/provisioning</code>, <code>prometheus/</code>"]
    c7["RDF4J Workbench<br/>add a repository in the UI"]
  end

  hub{{"any SPARQL 1.1 endpoint<br/>(container URL)"}}

  subgraph stores ["Stores (what you get)"]
    direction TB
    s1[("Fuseki<br/>http://fuseki:3030/ds/sparql<br/>sample data · writable")]
    s2[("Oxigraph<br/>http://oxigraph:7878/query<br/>sample data · writable")]
    s3[("Fuseki + GeoSPARQL<br/>http://fuseki-geosparql:3030/ds/sparql<br/>sample + WKT · writable")]
    s4[("Virtuoso<br/>http://virtuoso:8890/sparql<br/>sample data · writable")]
    s5[("QLever<br/>http://qlever:7001<br/>Olympics · read-only")]
    s6[("GraphDB<br/>http://graphdb:7200/repositories/ID<br/>empty · writable")]
    s7[("Ontop<br/>http://ontop:8080/sparql<br/>SQL demo · read-only")]
  end

  consumers --> hub --> stores

  classDef store fill:#fde68a,stroke:#b45309,color:#1c1917
  class s1,s2,s3,s4,s5,s6,s7 store
```

### The stores

| Store | Profile | Accepts SPARQL Update | `make load` fills it | What it holds | Mind |
|---|---|---|---|---|---|
| **Fuseki** | default | ✅ | ✅ | sample dataset in dataset `ds` | the default everything else assumes |
| **Oxigraph** | `oxigraph` | ✅ | ✅ | sample dataset | endpoint is `/query`, update is `/update`, store is `/store` |
| **Fuseki + GeoSPARQL** | `geosparql` | ✅ | ✅ | sample dataset + WKT points | a second, separate Fuseki; `geof:` functions, no admin UI |
| **Virtuoso** | `virtuoso` | ✅ (digest auth) | ✅ | sample dataset | Conductor at `/conductor`; GPL-2.0 |
| **QLever** | `qlever` | ❌ at runtime | ❌ (`make qlever-index` instead) | Olympics, 1.8M triples | different data, different IRIs; very fast reads |
| **GraphDB** | `graphdb` | ✅ | ❌ | nothing until you create a repository | restricted mode without a (free) licence; endpoint is per repository |
| **Ontop** | `ontop` | ❌ (virtual) | ❌ (it reads Postgres) | the seeded SQL demo tables | an R2RML/OBDA mapping, not a copy |

### The consumers

| Consumer | Default | How to switch | Works with | Caveats |
|---|---|---|---|---|
| **Trifid** (+ Blueprint, YASGUI, Graph Explorer) | Fuseki | `TRIFID_SPARQL_ENDPOINT_URL`, `TRIFID_DATASET_BASE_URL` | any endpoint | set the base URL to the IRIs in that store (Olympics data lives under `http://wallscope.co.uk/`) |
| **Blueprint** | Trifid's `/query` | `BLUEPRINT_FTS_DIALECT` | the store behind Trifid | full-text search dialects exist for `fuseki`, `qlever`, `graphdb` (and Stardog, Neptune); none for Oxigraph or Virtuoso. Empty until a Blueprint configuration graph is loaded, whatever the store |
| **sparql-proxy** (+ Sparklis, Sparnatural) | Fuseki | `SPARQL_PROXY_BACKEND` | any endpoint | read-only by design: updates are rejected. Sparnatural's class picker comes from `sparnatural/config.ttl`, written for the sample data |
| **Comunica** | Fuseki | `COMUNICA_SOURCES` (space-separated `sparql@URL`) | any number of endpoints | one listed source down fails the whole query, so list only profiles that are up |
| **Skosmos** | Fuseki `ds` | `skosmos/config.ttl` | any endpoint with the `Generic` dialect | `JenaText` dialect (fast search) is Fuseki-only and needs a text-indexed dataset |
| **Prez**, **grlc**, **RPT** | Fuseki | `PREZ_SPARQL_ENDPOINT`, `GRLC_SPARQL_ENDPOINT`, `RPT_SPARQL_ENDPOINT` | any endpoint | read-only consumers, no store-specific features used |
| **Graph Explorer** | Fuseki | `GRAPH_EXPLORER_CONNECTION_URL` | Fuseki, QLever, sparql-proxy, Virtuoso | its proxy only allows the origins in `PROXY_SERVER_ALLOWED_DB_ORIGINS` (`compose.yml`); add others there |
| **sparql-mcp** | Fuseki | `SPARQL_MCP_QUERY_URL`, `_UPDATE_URL`, `_GSP_URL` | any; updates need a writable store | point the query URL at sparql-proxy for a read-only agent |
| **Grafana** / **sparql-exporter** | Fuseki | `grafana/provisioning/datasources/`, `prometheus/prometheus.yml` | any endpoint | the exporter's example queries use the sample vocabulary |
| **JupyterLab**, **toolbox** | all three | `FUSEKI_URL`, `OXIGRAPH_URL`, `QLEVER_URL` already set | Fuseki, Oxigraph, QLever | notebooks pick the URL |
| **Flexible GraphRAG** | Fuseki | not switchable | Fuseki only | it creates its own dataset through Fuseki's admin API |
| **RDF4J Workbench** | none | add a "SPARQL endpoint proxy" repository | any endpoint, by container URL | the Workbench itself must be opened through the landing-page link |
| **LinkedPipes ETL** | none | per pipeline | any endpoint | each pipeline names its own source and target |
| **QLever UI** | QLever | `QLEVER_UI_BACKEND_URL` | QLever only (autocompletion uses its API) | browser-side: must be a host URL |

### Combinations that need care

- **Pointing Trifid or sparql-proxy at QLever** works for reading, but you are now browsing the
  Olympics, not the sample data: change `TRIFID_DATASET_BASE_URL`, expect Sparnatural's picker and
  Skosmos's vocabulary to come up empty, and `make load` will not have touched it.
- **Anything that writes** (sparql-mcp updates, LinkedPipes targets, Graph Store uploads) needs
  Fuseki, Oxigraph, Virtuoso, GeoSPARQL Fuseki or GraphDB. QLever, Ontop and sparql-proxy refuse.
- **GraphDB** needs a repository before any consumer can use it; the endpoint is
  `http://graphdb:7200/repositories/<id>`, and `make load` does not fill it.
- **Comunica is all-or-nothing**: a listed source that is down fails every federated query.
- **Browser-side apps need host ports.** `http://fuseki:3030` means nothing to your browser; that is
  why Blueprint, Sparklis and Sparnatural are configured with `http://localhost:8084/query` and
  `http://localhost:8090/sparql`, and why QLever UI's backend URL is `http://localhost:7001`.
  Change the host port in `.env` and those links follow; put the stack on another machine and they
  do not.
- **Two Fusekis are two stores.** The `geosparql` profile is a separate container with its own
  copy of the sample data; a GeoSPARQL query against the default Fuseki has no `geof:` functions.
- **GraphRAG writes into Fuseki, not `ds`.** Its triples live in the `flexible-graphrag` dataset,
  invisible to Trifid and friends unless you point them there.

---

## Where data comes from

```mermaid
flowchart LR
  sample["data/sample/*.ttl<br/>the stack describing itself"]
  csv["data/rml/services.csv<br/>and any CSV/JSON/XML"]
  docs["your documents"]
  sql[("Postgres<br/>seeded demo tables")]
  olympics["Olympics download<br/>(1.8M triples)"]

  load["make load<br/>scripts/load.sh"]
  rml["RML tools (profile tools)<br/>RMLMapper · YARRRML · SDM-RDFizer · RPT CLI"]
  sa["SPARQL Anything · :8093<br/>no mapping, Facade-X"]
  refine["OpenRefine · :3333"]
  etl["LinkedPipes ETL (profile lp-etl)"]
  graphrag["Flexible GraphRAG (profile graphrag)<br/>LLM extraction"]
  index["make qlever-index"]
  ontop["Ontop (profile ontop)<br/>R2RML mapping, nothing copied"]

  out["data/out/*.ttl"]

  fuseki[("Fuseki")]
  others[("Oxigraph · Virtuoso · GeoSPARQL Fuseki<br/>when their profile is up")]
  qlever[("QLever")]
  ontopep[("Ontop endpoint · :8089")]

  sample --> load
  load ==> fuseki
  load ==> others
  csv --> rml --> out --> load
  csv --> sa
  csv --> refine --> out
  docs --> graphrag ==> fuseki
  etl ==> fuseki
  olympics --> index ==> qlever
  sql --> ontop --> ontopep

  classDef store fill:#fde68a,stroke:#b45309,color:#1c1917
  class fuseki,others,qlever,ontopep,sql store
```

Thick arrows load triples into a store; thin ones produce files. Everything that produces a file
goes through `make load` to reach a store, which keeps one path for all of it.
