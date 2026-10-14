# Triplestores, RDF graph databases and SPARQL server infrastructure for a Docker Compose semantic web stack (state as of 2026-10-14)

Scope note: the target repo (MetaCoding-io/semantic-stack) already ships QLever, Fuseki, Oxigraph, RDF4J Workbench, OntoRefine, OpenRefine, rmlmapper-java, WebVOWL, Trifid, Blueprint, YASGUI and Comunica. Those are only mentioned below for "what's new" and the feature table. Metadata (stars, pushed date, license, archived flag) comes from the GitHub search API on 2026-10-14 unless another source is cited. Relative dates from Docker Hub ("2 months ago") were read on 2026-10-14.

## Key question 1: Which triplestores / RDF stores are actively maintained in 2025-2026 and ship Docker images?

### Takeaway
The realistic additions for a dev-machine compose stack are: Virtuoso Open Source (official image, GPL, 7.2.17 tags ~Aug 2026), GraphDB in "free mode" (official single image for all editions, 11.5.1 ~Sep 2026, proprietary), MillenniumDB (GPL-2.0, imfd/millenniumdb image, research-grade), AllegroGraph (franzinc/agraph 9.0.3, 5M-triple cap without license), RDF4J Server (same image family as the Workbench already present; RDF4J 6.0 with RDF 1.2/SPARQL 1.2 needs Java 25), Neo4j + n10s (official plugin switch), qEndpoint (HDT-backed, GPL-3, qacompany/qendpoint), Corese (now corese-stack org, SHACL + rules), Ontop (virtual KG over SQL, ontop/ontop 5.5.0) and SPARQL Anything (facadex/sparql-anything). Blazegraph and Kuzu are archived; Stardog and RDFox have no free self-hosted license; Tentris, Strabon, Halyard, Rya and Trellis are stale or require Hadoop-class infra.

### Cited Findings

#### Catalogue of candidate stores (name — repo — license — image — port — maintenance — gotchas)

**OpenLink Virtuoso Open Source Edition**
- Repo https://github.com/openlink/virtuoso-opensource — 975 stars, pushed 2026-10-12, license shows as "NOASSERTION" on GitHub (Virtuoso OSE is GPLv2; see gap), not archived — [GitHub search API](https://github.com/openlink/virtuoso-opensource)
- Official Docker image `openlink/virtuoso-opensource-7`; newest tags `latest`, `7`, `7.2`, `7.2.17`, `7.2.17-r25.1-g2850f18-ubuntu` and `-alpine` variants, all pushed "about 2 months ago" (≈ Aug 2026); `7.2.16` pushed ≈ 12 months ago — [Docker Hub tags](https://hub.docker.com/r/openlink/virtuoso-opensource-7/tags)
- Ports: 1111 (SQL/ODBC/JDBC/iSQL), 8890 (HTTP, SPARQL endpoint at /sparql, Conductor UI). Env: `DBA_PASSWORD`, `DAV_PASSWORD`, `*_FILE` variants for secrets, `VIRTUOSO_INI_FILE`, and `VIRT_<SECTION>_<KEY>` overrides, e.g. `VIRT_PARAMETERS_NUMBEROFBUFFERS=1000000`; `/initdb.d` runs `.sh`/`.sql` once at DB creation (ports stay closed until done; checkpoint after each script, relevant for `rdf_loader_run()`); persist by mounting `/database` — [Docker Hub overview](https://hub.docker.com/r/openlink/virtuoso-opensource-7)
- Virtuoso Open Source 7.2.16 release notes are dated October 10, 2025 (stability, HTTP/DAV/SOAP fixes, SPARQL optimiser and RDF Views fixes) — [OpenLink community](https://community.openlinksw.com/t/virtuoso-open-source-7-2-16-release-notes/5951)
- In the Wikimedia WDQS triple-store evaluation, Virtuoso and QLever both met acceptance criteria on WDBench and WGPB; Virtuoso "excels at minimum latency" — [WDQS Benchmark Results Report (PDF)](https://upload.wikimedia.org/wikipedia/commons/4/47/WDQS_Triple_Store_Evaluation_-_Benchmark_Results_Report.pdf)
- Gotchas: memory governed by `NumberOfBuffers`/`MaxDirtyBuffers` in virtuoso.ini (set via `VIRT_PARAMETERS_*`); bulk loading goes through `ld_dir()`/`rdf_loader_run()` in SQL rather than the SPARQL Graph Store protocol — [Docker Hub overview](https://hub.docker.com/r/openlink/virtuoso-opensource-7)

**Ontotext / Graphwise GraphDB (free mode)**
- Docker image `ontotext/graphdb`; most recent tag 11.5.1 (pushed "21 days ago" ≈ late Sep 2026), also 11.0.1, 9.11.2-se/-ee; since GraphDB 10.0 there is a single image for all editions and "the usage restrictions come from the applied license (or lack of license in case of the free version)"; port 7200 (UI/REST), 7300 (cluster RPC); data volume `/opt/graphdb/home`; license can be set via UI, `data/conf/graphdb.license` mount, or copied to `/opt/graphdb/home/conf`; example JVM option `-Dgraphdb.global.page.cache=3G` — [Docker Hub ontotext/graphdb](https://hub.docker.com/r/ontotext/graphdb/)
- Dockerfiles repo https://github.com/Ontotext-AD/graphdb-docker — 95 stars, pushed 2025-06-24 — [GitHub](https://github.com/Ontotext-AD/graphdb-docker)
- "From GraphDB 11 onwards, all editions (including GraphDB Free) require a license" which can be registered for on the GraphDB website; Free "has limits on concurrency, scalability, and available connectors" — [RDFLib docs on GraphDB](https://rdflib.readthedocs.io/en/stable/graphdb/)
- GraphDB 11 launched July 8, 2025 (LLM/GraphRAG "Talk to Your Graph", Model Context Protocol support) — [SiliconANGLE](https://siliconangle.com/2025/07/08/graphwise-enhances-graph-database-become-brains-ai-agents/); 11.1.0 (Aug 21, 2025) non-OpenAI models and DESCRIBE as CBD — [11.1.0 release notes](https://help.graphwise.ai/pp10.1/en/graphwise-documentation/graphwise-release-notes/graphdb-11-1-0-release-notes.html); 11.2.0 (Nov 27, 2025) vector search in Elasticsearch/OpenSearch connectors and native Python client — [11.2.0 release notes](https://help.graphwise.ai/en/graphdb/graphdb-release-notes/graphdb-11-2-0-release-notes.html); 11.3 (Feb 24, 2026) backup safeguards, expanded MCP, RDFLib-integrated Python client, Graphwise rebrand — [Graphwise blog](https://graphwise.ai/?p=250400)
- Gotchas: proprietary; free mode "limited functionality" (exact caps not verified, see Gaps); JVM heap and page cache need tuning; GraphDB 11 requires a (free) registered license key.

**MillenniumDB (IMFD, Chile)**
- Repo https://github.com/MillenniumDB/MillenniumDB — 267 stars, GPL-2.0, pushed 2026-09-30, description "Property Graph and RDF engine, still in development" — [GitHub search API](https://github.com/MillenniumDB/MillenniumDB)
- README: "fairly complete" SPARQL 1.1, plus a Cypher-like "Quad Model" language and early GQL; repository includes a Dockerfile; no GitHub releases; "not production ready" — [README](https://github.com/MillenniumDB/MillenniumDB); wiki repeats "not production ready yet" — [Wiki](https://github.com/MillenniumDB/MillenniumDB/wiki)
- Docker: wiki builds a local `mdb` image; `mdb import <file.ttl> /data/dbs/rdf/<db>` then `mdb server /data/dbs/rdf/<db>` publishing ports 1234 and 4321 (web UI at http://localhost:4321/), host `./data` mounted at `/data` — [Wiki/Docker](https://github.com/MillenniumDB/MillenniumDB/wiki/Docker)
- Docker Hub image `imfd/millenniumdb` (`latest`, arm64 and amd64 tags, ~16 MB, updated ≈ Aug 2026, "No overview available") — [Docker Hub](https://hub.docker.com/r/imfd/millenniumdb)
- Benchmarked on Wikidata by Patel-Schneider (ISWC 2025 Wikidata workshop): QLever fastest of Blazegraph, MillenniumDB, QLever, Virtuoso — [CEUR Vol-4108 paper3](https://ceur-ws.org/Vol-4108/paper3.pdf)
- Gotchas: import step builds an on-disk DB (no live SPARQL Update documented in README); GPL-2.0; image lacks docs on Docker Hub.

**Franz AllegroGraph (free without license)**
- Docker image `franzinc/agraph`, `latest` = AllegroGraph 9.0.3; run with `-e AGRAPH_SUPER_USER=... -e AGRAPH_SUPER_PASSWORD=... -p 10000-10035:10000-10035 --shm-size 2g`; AGWebView at port 10035; data lives inside the container under `/agraph/data/`, config `/agraph/etc/agraph.cfg`; "running without a license is restricted to 5 million triples" — [Franz Docker docs](https://franz.com/agraph/support/documentation/current/docker.html)
- Editions page: Free up to 5 Million triples, Enterprise unlimited — [AllegroGraph editions](https://allegrograph.com/allegrograph-editions/); Wikipedia lists stable release 9.0 / May 2026 — [Wikipedia](https://en.wikipedia.org/wiki/AllegroGraph)
- Gotchas: proprietary; 5M triple cap; needs `--shm-size`; requires a port range, not one port.

**Eclipse RDF4J Server (not just Workbench)**
- Repo https://github.com/eclipse-rdf4j/rdf4j — 420 stars, BSD-3-Clause, pushed 2026-10-13 — [GitHub search API](https://github.com/eclipse-rdf4j/rdf4j)
- RDF4J 6.0.0 released July 2, 2026 with RDF 1.2 and SPARQL 1.2 support; 6.0.1 on August 20, 2026 — [rdf4j.org](https://rdf4j.org/); 6.0.0 notes: triple terms first-class, SPARQL 1.2 parser/algebra, "Java 25 is the minimum supported Java version", Jakarta Servlet/Spring 7/Jetty 12/Tomcat 11, Solr SAIL removed, Docker configs now use Java 25 — [6.0.0 release notes](https://rdf4j.org/release-notes/6.0.0)
- Server/Workbench run on port 8080 at `/rdf4j-server` and `/rdf4j-workbench`; Tomcat default, `APP_SERVER=jetty` alternative; Java 25+ required — [Server & Workbench docs](https://rdf4j.org/documentation/tools/server-workbench/)
- The existing stack pins `eclipse/rdf4j-workbench:5.2.2`; the `eclipse/rdf4j-workbench` image bundles both server and workbench in one Tomcat; a separate `eclipse/rdf4j-server` Docker Hub page returned 404 on 2026-10-14 — [Docker Hub 404](https://hub.docker.com/r/eclipse/rdf4j-server)
- Gotchas: upgrade from 5.x to 6.x implies Java 25 and Jakarta namespace; ShaclSail, Lucene SAIL and GeoSPARQL are configured per repository (see feature table).

**Neo4j + neosemantics (n10s)**
- Repo https://github.com/neo4j-labs/neosemantics — 968 stars, pushed 2026-10-09, default branch `2025.06` — [GitHub search API](https://github.com/neo4j-labs/neosemantics); latest release 2025.06.1 (16 Jun 2025, "Bugfix release for Jackson CVE"), previous 5.26.0 (Sep 2024) — [Releases](https://github.com/neo4j-labs/neosemantics/releases)
- Neo4j Docker image supports `NEO4J_PLUGINS` with values `apoc`, `apoc-extended`, `bloom`, `genai`, `graph-data-science`, `n10s` — [Neo4j Docker plugins docs](https://neo4j.com/docs/operations-manual/current/docker/plugins/); current docs use image `neo4j:2026.09.0` with ports 7474/7687 — [Neo4j Docker operations](https://neo4j.com/docs/operations-manual/current/docker/operations/)
- Gotchas: n10s is an RDF import/export + SHACL layer over a property graph, not a SPARQL endpoint (queries are Cypher); n10s releases lag Neo4j calendar versions (latest n10s is 2025.06.1 while Neo4j is at 2026.09).

**qEndpoint (HDT-backed SPARQL endpoint, The QA Company)**
- Repo https://github.com/the-qa-company/qEndpoint — "highly scalable RDF triple store with full-text and GeoSPARQL support", built on Spring + RDF4J + RDF-HDT; GPL-3.0; 109 stars, 1,034 commits, 41 open issues; Docker `qacompany/qendpoint` on port 1234, `qacompany/qendpoint-wikidata` with `HDT_BASE=wikidata_truthy` (≥6 GB) or `wikidata_all` (≥10 GB); default `MEM_SIZE` 6G, "not below 4G for large datasets"; install examples reference 1.2.3 — [GitHub README](https://github.com/the-qa-company/qEndpoint)
- Related: HDT Java tooling repo https://github.com/rdfhdt/hdt-java — 104 stars, pushed 2026-08-31 — [GitHub search API](https://github.com/rdfhdt/hdt-java)
- Gotchas: GPL-3; RAM-heavy defaults; data arrives as HDT index files (convert first) or via `/api/endpoint/load`.

**Corese (Inria Wimmics → corese-stack)**
- Old monorepo https://github.com/Wimmics/corese is archived (113 stars, archived=true, updated 2026-09-08) — [GitHub search API](https://github.com/Wimmics/corese)
- New org https://github.com/corese-stack: `corese-core` (RDF, SPARQL 1.1, RDFS/OWL reasoning, SHACL; updated Oct 2, 2026), `corese-server` (SPARQL 1.1 Protocol HTTP endpoint and REST API; updated Jun 17, 2026), `corese-command` (CLI; Dec 9, 2025), `corese-gui` (JavaFX; Apr 27, 2026), `corese-python` (LGPL-2.1; Jan 17, 2025) — [corese-stack org](https://github.com/corese-stack); corese-core 4.6.3 on Maven Central under CeCILL-C — [Maven Central](https://central.sonatype.com/artifact/fr.inria.corese/corese-core)
- Gotchas: corese-server has no GitHub releases page entries ("There aren't any releases here") — [corese-server releases](https://github.com/corese-stack/corese-server/releases); Docker image name not verified (see Gaps); CeCILL-C license (French LGPL-like).

**Ontop (virtual knowledge graph over relational DBs)**
- Repo https://github.com/ontop/ontop — 976 stars, Apache-2.0, pushed 2026-09-21 — [GitHub search API](https://github.com/ontop/ontop); releases: Ontop 5.5.0 (14 Feb 2026, latest), 5.4.0 (28 Sep 2025), 5.3.1 (29 Sep 2025); Docker image `ontop/ontop` — [Releases](https://github.com/ontop/ontop/releases)
- Why: exposes PostgreSQL/MySQL/etc. as a SPARQL endpoint via R2RML/OBDA mappings without materialising triples; complements rmlmapper (materialisation).

**SPARQL Anything (query non-RDF files with SPARQL)**
- Repo https://github.com/SPARQL-Anything/sparql.anything — 307 stars, Apache-2.0, pushed 2026-10-13 — [GitHub search API](https://github.com/SPARQL-Anything/sparql.anything); v1.3.0-RC2 and RC1 (8 Oct 2026, pre-releases) with Docker images `facadex/sparql-anything:v1.3.0-RC2`; nightly v1.3-DEV 2026-10-13; server jar listens on port 3000 — [Releases](https://github.com/SPARQL-Anything/sparql.anything/releases)

**AtomGraph LinkedDataHub (Linked Data application platform on Fuseki)**
- Repo https://github.com/AtomGraph/LinkedDataHub — 630 stars, Apache-2.0, pushed 2026-10-13 — [GitHub search API](https://github.com/AtomGraph/LinkedDataHub); Docker Compose-based (`atomgraph/fuseki`, nginx, varnish, smtp; LDH image built locally), HTTP 81 / HTTPS 4443 by default, needs generated SSL certs and secrets, graph versioning since 5.9.0, "Version 6" UI redesign — [README](https://github.com/AtomGraph/LinkedDataHub)

**Tentris (DICE group, Paderborn) — research prototype**
- Releases: v1.5.0 (30 Jul, latest; adds `INSERT DATA`/`DELETE DATA` with reader-writer lock, references the ISWC 2025 paper "Efficient Updates for Worst-Case Optimal Join Triple Stores"), v1.4.0 (02 Dec), v1.3.1 (12 Apr); page calls this the research prototype and says the commercial edition "is SPARQL feature-complete" with a free Beta — [Releases](https://github.com/dice-group/tentris/releases)
- Docker Hub `dicegroup/tentris_server` newest tag 1.1.3 pushed over 2 years ago, default port 9080 — [Docker Hub](https://hub.docker.com/r/dicegroup/tentris_server)
- Gotchas: Docker image stale relative to GitHub releases; limited SPARQL coverage in the open prototype.

**Stardog (no free self-hosted tier)**
- Docker image `stardog/stardog` (`latest` only, ~761 MB) — [Docker Hub](https://hub.docker.com/r/stardog/stardog); server will not start without a license file in the mounted home; image requires x86-64, ARM/Apple Silicon not supported — [Stardog Docker docs](https://docs.stardog.com/install-stardog/docker); Stardog staff: no free licenses for on-prem, use free Stardog Cloud instead — [Stardog community](https://community.stardog.com/t/how-can-one-obtain-the-license-for-the-free-version/5373)

**Oxford Semantic RDFox (trial license only)**
- Docker images `oxfordsemantic/rdfox` and `oxfordsemantic/rdfox-init`; endpoint port 12110; requires a valid in-date license mounted at `/opt/RDFox/RDFox.lic` (or `RDFOX_LICENSE_CONTENT`); docs version selector lists 7.7 — [RDFox Docker docs](https://docs.oxfordsemantic.tech/docker.html); trial licenses are requested from the RDFox website per a third-party demo repo — [agnos-ai/northwind](https://github.com/agnos-ai/northwind)

**AnzoGraph DB (Cambridge Semantics) — free edition**
- All deployments include an embedded, non-expiring anonymous free-edition license valid for single-server use with an 8 GB RAM usage cap; registering raises the cap to 16 GB; Docker is a supported single-container deployment; images distributed via Red Hat Catalog and Docker Hub — [AnzoGraph docs (archived v2.x)](https://docs.cambridgesemantics.com/anzograph/archive/v2.4/userdoc/platforms-tools.htm), [FAQ](https://docs.cambridgesemantics.com/anzograph/userdoc/faq.htm)
- Gotcha: the only docs found are archived v2.x pages; current image name/tag not verified (see Gaps).

**Blazegraph and forks**
- Repo https://github.com/blazegraph/database is archived (987 stars, archived=true) — [GitHub search API](https://github.com/blazegraph/database); Wikimedia is migrating WDQS off Blazegraph ("database migration for WDQS, starting FY26") — [Phabricator T413229](https://phabricator.wikimedia.org/T413229); QLever is a candidate replacement — [Wikipedia: QLever](https://en.wikipedia.org/wiki/QLever)

**Apache Rya, Halyard**
- Rya mirror https://github.com/apache/rya — 115 stars, pushed 2026-07-22 (mirror activity), requires Accumulo/MongoDB backends — [GitHub search API](https://github.com/apache/rya)
- Halyard https://github.com/Merck/Halyard — 114 stars; latest releases 3.2 "Senohraby" (05 Dec, HBase 2.x/Hadoop 3, RDF4J 3.0.3) and 2.5 (HBase 1.x); no Docker image on releases page — [Releases](https://github.com/Merck/Halyard/releases)

**Strabon (geospatial, stSPARQL)**
- Official download page points to GitHub but shows no version; W3C wiki entry last modified 2013; Big Data Europe wiki references Docker image `bde2020/docker-strabon` — [W3C wiki](https://www.w3.org/2001/sw/wiki/Strabon), [BDE wiki](https://github.com/big-data-europe/README/wiki/Strabon); the `bde2020/docker-strabon` Docker Hub page returned 404 on 2026-10-14 — [Docker Hub 404](https://hub.docker.com/r/bde2020/docker-strabon); esipfed/strabon mirror exists — [GitHub](https://github.com/esipfed/strabon)

**Property-graph / multi-model DBs sometimes listed as "RDF-capable"**
- Kuzu: repo archived on October 10, 2025; last PyPI 0.11.3; fork RyuGraph by Predictable Labs — [LibHunt](https://www.libhunt.com/posts/1452784-kuzu-db-devs-no-longer-supporting-the-project), [RyuGraph blog](https://blog.ryugraph.io/posts/introducing-predictable-labs-and-ryugraph); GitHub shows kuzudb/kuzu archived=true — [GitHub search API](https://github.com/kuzudb/kuzu)
- SurrealDB: 33,131 stars, pushed 2026-10-14, document-graph DB with no RDF/SPARQL in its topics — [GitHub search API](https://github.com/surrealdb/surrealdb)
- TerminusDB: 3,440 stars, Apache-2.0 (per repo), latest v12.0.8 (12 Oct 2026), v12.0.7 (10 Aug), v12.0.6 (24 Jun); Docker `terminusdb/terminusdb-server` updated 1 day before 2026-10-14 — [Releases](https://github.com/terminusdb/terminusdb/releases), [Docker Hub](https://hub.docker.com/r/terminusdb/terminusdb-server)
- Dgraph: v25.3.x stable line (first v25.3.0 Mar 2026), query language DQL, image `dgraph/standalone`; no SPARQL found in v25 docs — [Dgraph releases](https://docs.dgraph.io/v25.1/releases/), [v25 preview](https://docs.hypermode.com/dgraph/v25-preview)
- Amazon Neptune: AWS docs only describe connecting to a live cluster; no local emulator surfaced — [Neptune SPARQL docs](https://docs.aws.amazon.com/ko_kr/neptune/latest/userguide/access-graph-sparql.html); `aws/graph-notebook` (823 stars, Apache-2.0, pushed 2026-09-01) is a Jupyter client for SPARQL/Gremlin endpoints — [GitHub search API](https://github.com/aws/graph-notebook)

**Brand-new Rust stores (2026, early-stage)**
- Open Triplestore https://github.com/philipperenzen/open-triplestore — created 2026-06-04, 1 star; Oxigraph core + Axum + Svelte UI; AGPL-3.0 + Commons Clause ("source-available, not OSI open source"); claims SPARQL 1.1/1.2, GeoSPARQL 1.0/1.1, OWL 2 RL/EL/QL, SHACL Core, ShEx, LDP 1.0, DCAT 3, full-text, JWT/RBAC; image `ghcr.io/philipperenzen/open-triplestore:latest`, port 7878, version 0.7.0 — [README](https://github.com/philipperenzen/open-triplestore); its own issue reports queries ~6x slower than upstream Oxigraph 0.5.11 on BSBM 10k — [Issue #468](https://github.com/philipperenzen/open-triplestore/issues/468)
- sparq https://github.com/sparq-org/sparq — created 2026-06-07, 13 stars, 1,052 open issues, MIT; "experimental research engine… API is unstable and pre-1.0"; Dockerfile but no published image name; HTTP server example on 3000 — [README](https://github.com/sparq-org/sparq)

#### Existing-stack stores: notable 2025-2026 versions (brief)
- QLever: v0.6.0 (13 Aug; latest) adds runtime index swap via `rebuild-index`, Prometheus `/metrics`, WASM npm package, CONSTRUCT dedup; v0.5.50 (17 Jul) publishes version-tagged Docker images on release tags; v0.5.44 (21 Jan) official Debian/Ubuntu/macOS packages — [Releases](https://github.com/ad-freiburg/qlever/releases); apt packages "since 21.01.2026"; Homebrew is Apple Silicon only — [Quickstart](https://docs.qlever.dev/quickstart/); Docker Hub `adfreiburg/qlever` tags `latest`, `0.6.0`, `0.6`, `commit-<sha>`, `pr-<n>` — [Docker Hub](https://hub.docker.com/r/adfreiburg/qlever); SPARQL 1.1 compliant "since the end of June 2025", conformance results at qlever.dev/sparql-conformance — [QLever wiki](https://github-wiki-see.page/m/ad-freiburg/qlever/wiki/Current-deviations-from-the-SPARQL-1.1-standard); funded by NGI Search with 30.06.2025 deadline — [NGI](https://ngi.eu/funded_solution/ngi-search34/)
- Oxigraph: 0.5.0 on 2025-09-13 (RDF 1.2/SPARQL 1.2 arrived in 0.5.0-beta.1, 2025-06-20; JSON-LD 1.1 in 0.5.5, 2026-02-14; 0.5.7 2026-04-19) — [CHANGELOG](https://raw.githubusercontent.com/oxigraph/oxigraph/main/CHANGELOG.md); 0.5.8 (28 Apr) new `/sparql` path for query+update and "a significant set of new" GeoSPARQL functions; 0.5.11 (02 Sep) latest — [Releases](https://github.com/oxigraph/oxigraph/releases); image `ghcr.io/oxigraph/oxigraph`, `serve --location /data --bind 0.0.0.0:7878` — [CLI README](https://raw.githubusercontent.com/oxigraph/oxigraph/main/cli/README.md); dual Apache-2.0/MIT, "preliminary" RDF 1.2/SPARQL 1.2, partial GeoSPARQL via `spargeo` — [README](https://github.com/oxigraph/oxigraph)
- Apache Jena: tags jena-6.2.0 (Jul 27, 2026), 6.1.0 (May 3, 2026), 6.0.0 (Jan 27, 2026), 5.6.0 (Oct 10, 2025), 5.5.0 (Jul 14, 2025) — [Tags](https://github.com/apache/jena/tags); "Jena6 requires Java 21" — [Download](https://jena.apache.org/download/). The stack pins `secoresearch/fuseki:5.5.0`, i.e. two major-line steps behind.
- RDF4J: stack pins `eclipse/rdf4j-workbench:5.2.2`; 6.0.x (Jul-Aug 2026) requires Java 25 — [6.0.0 notes](https://rdf4j.org/release-notes/6.0.0)

### Inferences
- The only widely adopted open-source stores missing from the stack are Virtuoso OSE and (as an "other engine" for benchmarking) MillenniumDB; both have small official-ish images and clear ports (8890 / 4321). Virtuoso is the strongest single addition because it is the other engine (with QLever) that passed Wikimedia's WDQS acceptance tests.
- GraphDB free mode is the most practical proprietary addition: single official image, port 7200, RDF4J-compatible REST API, built-in reasoning/SHACL/connectors; the cost is a mandatory license registration since v11 and unverified concurrency caps.
- Year inference: Oxigraph releases 0.5.8-0.5.11 and QLever v0.6.0 are 2026 releases (the CHANGELOG dates 0.5.7 on 2026-04-19 and QLever's 21 Jan package release matches the documented 21.01.2026 apt launch); GraphDB 11.5.1 ≈ September 2026; Virtuoso 7.2.17 ≈ August 2026 (release notes for 7.2.17 not located).
- Blazegraph (archived), Kuzu (archived), Tentris (stale image), Strabon (dead image), Halyard/Rya (Hadoop-class dependencies) should be excluded from a laptop compose file.
- The two June-2026 Rust projects (Open Triplestore, sparq) are too young (1 and 13 stars, non-OSI or pre-1.0) to add, but worth a watch list; Open Triplestore is interesting as an "Oxigraph + UI + auth + OWL/SHACL" bundle if its license is acceptable.

### Gaps
- GraphDB Free exact restrictions (concurrent query limit, cores, connector list) could not be retrieved: ontotext.com and help.graphwise.ai pages fetched empty or 404 on 2026-10-14. Only "limited functionality" / "limits on concurrency, scalability, and available connectors" is sourced.
- GraphDB 11.4/11.5 release notes and exact dates not located (only Docker Hub's relative "21 days ago" for 11.5.1).
- Virtuoso 7.2.17 release notes/date not found; GitHub reports license "NOASSERTION" (the GPLv2 licensing of VOS was not re-verified from a primary page).
- Jena 6.x headline features (RDF 1.2/SPARQL 1.2 status) not verified; only tag dates and the Java 21 requirement.
- MillenniumDB: no version numbers (no GitHub releases); whether the `imfd/millenniumdb` image is officially maintained by the project is implied by the namespace only.
- Corese server Docker image name/tag and port not verified (no releases on corese-stack/corese-server).
- AnzoGraph current image name/tag and whether the free edition is still offered in 2026 not verified (docs found are archived v2.x).
- Tentris commercial "free Beta" terms and image not verified.
- Stardog default port (5820) and RDFox trial duration not confirmed from the fetched pages.

## Key question 2: Which SPARQL server-side infrastructure is useful (TPF/LDF, proxies/caches, LDP, versioning, logging/monitoring, auth)?

### Takeaway
The best-maintained pieces are dbcls/sparql-proxy (cache + job queue + query log + update blocking; `ghcr.io/dbcls/sparql-proxy`, port 3000, pushed Sep 2026), Community Solid Server (LDP/Solid, `solidproject/community-server`, port 3000, v7.2.0 with 8.0 alphas), LDF Server.js (TPF; active repo but the Docker Hub `server.js` image is deprecated in favour of `linkeddatafragments/server`), and for versioning Quit Store (`aksw/quitstore`, Git-backed, GPL-3) or RDF Delta (Jena-based change log). Monitoring is already available natively: Fuseki `/$/metrics` (Prometheus) and QLever `/metrics` since v0.6.0; authentication is best handled by a generic reverse proxy plus sparql-proxy's update blocking.

### Cited Findings

**SPARQL proxy / cache / job control / logging**
- dbcls/sparql-proxy — https://github.com/dbcls/sparql-proxy — MIT, 38 stars, pushed 2026-09-01; "provides cache, job control, and logging for any SPARQL endpoint" — [GitHub search API](https://github.com/dbcls/sparql-proxy); features: validates queries and omits SPARQL Update, job scheduling with `MAX_CONCURRENCY`/`MAX_WAITING`, admin dashboard at `/admin`, cache stores `null|file|memory|redis|memcache`, `QUERY_LOG_PATH` for query/response logging, `MAX_LIMIT` cap, experimental query splitting and plugins; image `ghcr.io/dbcls/sparql-proxy`, listens on 3000, env `SPARQL_BACKEND` (required), `ADMIN_USER`/`ADMIN_PASSWORD` (default admin/password), `JOB_TIMEOUT` 300000 ms — [README](https://github.com/dbcls/sparql-proxy)
- zazuko/sparql-proxy — https://github.com/zazuko/sparql-proxy — 4 stars, last updated 2022-11-28 (Trifid, already in the stack, is Zazuko's maintained successor path) — [GitHub search API](https://github.com/zazuko/sparql-proxy); npm `@zazuko/sparql-proxy` supports GET/POST and basic auth — [npm](https://npmjs.com/package/@zazuko/sparql-proxy)
- SPARQLES monitors availability/performance of public endpoints (external health checks, not a proxy) — [Semantic Web Journal](https://journals.sagepub.com/doi/full/10.3233/SW-170254)

**Linked Data Fragments / TPF**
- LinkedDataFragments/Server.js — https://github.com/LinkedDataFragments/Server.js — MIT, 181 stars, pushed 2026-09-25 — [GitHub search API](https://github.com/LinkedDataFragments/Server.js); Lerna monorepo (`@ldf/server`, `@ldf/preset-qpf`), datasources HDT, SPARQL, N3 (Turtle/TriG/N-Quads), JSON-LD, RDFa, composite; JSON config; example `ldf-server config.json 5000 4`; README still cites Node 10+ and Yarn workspaces — [README](https://github.com/LinkedDataFragments/Server.js)
- Docker Hub `linkeddatafragments/server.js` is marked deprecated (last pushed over 7 years ago) and points to `linkeddatafragments/server` — [Docker Hub](https://hub.docker.com/r/linkeddatafragments/server.js)
- Comunica (already in stack) is the matching TPF client; Comunica repo 615 stars, pushed 2026-10-13 — [GitHub search API](https://github.com/comunica/comunica)

**LDP / Solid servers**
- Community Solid Server — https://github.com/CommunitySolidServer/CommunitySolidServer — 608 stars, pushed 2026-10-13 — [GitHub search API](https://github.com/CommunitySolidServer/CommunitySolidServer); releases v7.2.0 (22 Jul, latest; adds `pim:storage` triple, data-corruption handling, security docs), v8.0.0-alpha.3 (13 Mar), v8.0.0-alpha.2 (03 Mar; SPARQL accessor content-type), v7.1.9 (03 Mar) — [Releases](https://github.com/CommunitySolidServer/CommunitySolidServer/releases); Docker `solidproject/community-server` (`latest`=`7`, `8.0.0-alpha.3` tag), `docker run -v ~/Solid:/data -p 3000:3000 solidproject/community-server:latest` — [Docker Hub](https://hub.docker.com/r/solidproject/community-server), [tags](https://hub.docker.com/r/solidproject/community-server/tags)
- Trellis LDP — https://github.com/trellis-ldp/trellis — 110 stars, updated 2026-10-04 — [GitHub search API](https://github.com/trellis-ldp/trellis); latest release 0.19.0 (17 Sep; MicroProfile 4.x / Quarkus 2.x), 0.18.0 (27 Apr), 0.17.2 (12 Mar); years not shown — [Releases](https://github.com/trellis-ldp/trellis/releases); image `trellisldp/trellis-triplestore` exists — [Docker Hub](https://hub.docker.com/r/trellisldp/trellis-triplestore)
- LinkedDataHub (see Q1) is an LDP-style app platform on Fuseki with graph versioning — [README](https://github.com/AtomGraph/LinkedDataHub)

**RDF versioning**
- Quit Store — https://github.com/AKSW/QuitStore — GPL-3.0, 116 stars, updated 2026-10-06; "Quads in Git"; SPARQL 1.1 Query/Update at `/sparql`, per-branch/commit endpoints `/sparql/<branch>`, `/sparql/<commit>`, git branch/merge/pull/push, provenance endpoint `/provenance` and `/blame`; Docker `aksw/quitstore` (also GHCR) exposing 8080; "still under development", pyinstaller binaries "currently broken"; version 0.25.4 appears in a pipx example — [README](https://github.com/AKSW/QuitStore)
- RDF Delta (Jena change-log/patch server) — https://github.com/afs/rdf-delta — 92 stars, pushed 2026-09-01 — [GitHub search API](https://github.com/afs/rdf-delta); releases 1.1.2 (17 Aug), 1.1.1 (10 May), 1.1.0 (19 Dec; Jena 4.3.2) — years not shown — [Releases](https://github.com/afs/rdf-delta/releases)
- OSTRICH — https://github.com/rdfostrich/ostrich — 52 stars, C++, updated 2026-08-07 — [GitHub search API](https://github.com/rdfostrich/ostrich); 2025 research extends OSTRICH with configurable snapshot strategies; earlier work found it "unusable for datasets with a large number of versions" motivating bidirectional delta chains — [Semantic Web Journal](https://www.semantic-web-journal.net/content/optimizing-storage-rdf-archives-using-bidirectional-delta-chains)
- R43ples: no maintenance signal found (only mentioned in comparison tables) — [arXiv 2210.02534](https://arxiv.org/pdf/2210.02534)
- TerminusDB offers built-in versioning (diff API, history endpoint) but with its own document/graph model and WOQL/GraphQL rather than SPARQL — [Releases](https://github.com/terminusdb/terminusdb/releases)

**Monitoring / query logging**
- Fuseki exposes `/$/ping` (liveness), `/$/stats` (JSON per-dataset counters) and `/$/metrics` (Prometheus, DB + JVM) — must be enabled in Fuseki/main via CLI flags or `fuseki:pingEP`/`fuseki:statsEP`/`fuseki:metricsEP` — [Fuseki server info docs](https://jena.apache.org/documentation/fuseki2/fuseki-server-info.html)
- QLever v0.6.0 adds a Prometheus `/metrics` endpoint — [QLever releases](https://github.com/ad-freiburg/qlever/releases); docs have a "Monitoring" reference page — [docs.qlever.dev](https://docs.qlever.dev/)
- dbcls/sparql-proxy query/response logging via `QUERY_LOG_PATH` — [README](https://github.com/dbcls/sparql-proxy)

**Authentication in front of endpoints**
- No single open-source product covering auth + proxy + logging was found; common pattern is a reverse proxy (Apache mod_proxy/nginx/Traefik) exposing only the query path plus sparql-proxy for logging — [FilteredPush Fuseki guide](https://filteredpush.sourceforge.net/pages/fuseki.html); dbcls/sparql-proxy requires an admin login and blocks updates by default — [README](https://github.com/dbcls/sparql-proxy)

### Inferences
- dbcls/sparql-proxy is the single highest-value infra addition: it hardens any of the stack's endpoints (QLever has one root endpoint for query/update/GSP, so blocking updates at the proxy matters), adds caching and gives a query log; it is tiny and runs on port 3000.
- A TPF server adds a second access pattern that Comunica already understands; the published `linkeddatafragments/server` image should be verified (tags/dates not fetched) before pinning — otherwise build from the repo Dockerfile.
- For versioning, Quit Store is the only Docker-ready SPARQL-fronted option; RDF Delta is better suited to replicating Fuseki datasets than to interactive "git for RDF".
- Community Solid Server is the only actively released LDP implementation; Trellis's release stream appears dormant (release notes mention Quarkus 2.x-era dependencies).

### Gaps
- `linkeddatafragments/server` Docker Hub tags/last-push date not fetched.
- Years for CSS, Trellis, RDF Delta releases are not shown on GitHub release pages (day/month only); CSS v7.2.0 is likely 2026 (follows 7.1.9 and 8.0 alphas from March) but this is inferred.
- No maintained, dedicated "SPARQL authentication proxy" project was found; oauth2-proxy/Traefik style solutions are generic and were not researched further.
- Quit Store latest release date/tag not available (GitHub releases empty).

## Key question 3: What is new in 2025-2026 (new projects, 1.0 releases, funding, adoption)?

### Takeaway
2025-2026 is dominated by standards moves (RDF 1.2 / SPARQL 1.2 landing in RDF4J 6.0 and Oxigraph 0.5; QLever reaching full SPARQL 1.1 conformance with NGI funding), major-version jumps (Jena 6, GraphDB 11 with LLM/MCP features, AllegroGraph 9, Neo4j calendar versions), the Wikidata Query Service migration away from Blazegraph, and consolidation/attrition (Blazegraph and Kuzu archived; Corese moved to a new org). New stores are early-stage Rust projects.

### Cited Findings
- QLever: full SPARQL 1.1 compliance incl. Update and Graph Store HTTP Protocol in June 2025, funded by EU NGI Search — [Wikipedia](https://en.wikipedia.org/wiki/QLever), [NGI Search](https://ngi.eu/funded_solution/ngi-search34/); official apt packages since 21.01.2026 — [Quickstart](https://docs.qlever.dev/quickstart/); v0.6.0 (Aug 2026) with runtime index swap and Prometheus metrics — [Releases](https://github.com/ad-freiburg/qlever/releases)
- Wikidata Query Service: WDQS backend migration "starting FY26" considering open-source vendors; Blazegraph-specific extensions (named subqueries, geospatial services) to be removed in favour of standards-compliant SPARQL 1.1 — [Phabricator T413229](https://phabricator.wikimedia.org/T413229), [WDQS evaluation report](https://upload.wikimedia.org/wikipedia/commons/4/47/WDQS_Triple_Store_Evaluation_-_Benchmark_Results_Report.pdf); the report judged Oxigraph as missing critical SPARQL 1.1 features for WDQS — same report
- Patel-Schneider benchmark (ISWC 2025 Wikidata Workshop): QLever fastest among Blazegraph, MillenniumDB, QLever, Virtuoso — [CEUR Vol-4108](https://ceur-ws.org/Vol-4108/paper3.pdf)
- RDF4J 6.0.0 (July 2, 2026) brings RDF 1.2 and SPARQL 1.2; 6.0.1 August 20, 2026; Java 25 minimum — [rdf4j.org](https://rdf4j.org/), [release notes](https://rdf4j.org/release-notes/6.0.0)
- Oxigraph 0.5.0 (2025-09-13) line with RDF 1.2/SPARQL 1.2 (beta June 2025), JSON-LD 1.1 (Feb 2026), expanded GeoSPARQL (Apr 2026) — [CHANGELOG](https://raw.githubusercontent.com/oxigraph/oxigraph/main/CHANGELOG.md), [Releases](https://github.com/oxigraph/oxigraph/releases)
- Apache Jena 6.0.0 on Jan 27, 2026 (Java 21), 6.2.0 on Jul 27, 2026 — [Tags](https://github.com/apache/jena/tags), [Download](https://jena.apache.org/download/)
- GraphDB 11 launched July 8, 2025 under the Graphwise brand with GraphRAG and Model Context Protocol support; 11.3 in Feb 2026 — [SiliconANGLE](https://siliconangle.com/2025/07/08/graphwise-enhances-graph-database-become-brains-ai-agents/), [Graphwise](https://graphwise.ai/?p=250400)
- AllegroGraph 9.0 stable (May 2026), Docker `latest` = 9.0.3 — [Wikipedia](https://en.wikipedia.org/wiki/AllegroGraph), [Franz Docker docs](https://franz.com/agraph/support/documentation/current/docker.html)
- Kuzu archived October 10, 2025; RyuGraph fork announced — [LibHunt](https://www.libhunt.com/posts/1452784-kuzu-db-devs-no-longer-supporting-the-project), [RyuGraph](https://blog.ryugraph.io/posts/introducing-predictable-labs-and-ryugraph)
- Blazegraph GitHub repo archived — [GitHub search API](https://github.com/blazegraph/database)
- Corese moved from archived Wimmics/corese to the corese-stack organization with modular repos active through Oct 2026 — [corese-stack](https://github.com/corese-stack)
- Tentris v1.5.0 adds updates, tied to ISWC 2025 paper — [Releases](https://github.com/dice-group/tentris/releases)
- Neo4j n10s moved to calendar versioning (2025.06.1, June 2025) — [Releases](https://github.com/neo4j-labs/neosemantics/releases)
- New 2026 Rust stores: sparq (MIT, created 2026-06-07, experimental) and Open Triplestore (AGPL+Commons Clause, created 2026-06-04, v0.7.0) — [GitHub search API](https://github.com/sparq-org/sparq), [Open Triplestore](https://github.com/philipperenzen/open-triplestore)
- Other 2026 activity: Ontop 5.5.0 (Feb 14, 2026) — [Releases](https://github.com/ontop/ontop/releases); SPARQL Anything 1.3.0 RCs (Oct 8, 2026) — [Releases](https://github.com/SPARQL-Anything/sparql.anything/releases); rdf_fdw 2.6.0 PostgreSQL FDW for SPARQL endpoints (June 23, 2026) — [PGXN](https://pgxn.org/dist/rdf_fdw/); Grafeo, a pure-Rust graph DB (811 stars, Apache-2.0, pushed 2026-10-13) appears in triplestore searches but its RDF support was not verified — [GitHub search API](https://github.com/GrafeoDB/grafeo)

### Inferences
- Version drift inside the existing stack is itself a 2026 finding: Fuseki 5.5.0 (Jul 2025) vs Jena 6.2.0; RDF4J Workbench 5.2.2 vs 6.0.1; both upgrades cross a Java major (21 / 25) and should be done deliberately.
- SPARQL 1.2 is now testable locally with three engines (Oxigraph 0.5, RDF4J 6, Jena 6 — the latter unverified), which is a selling point for the stack.
- No 2025-2026 "1.0" of a new open-source triplestore was found; the field's new entrants are pre-1.0 Rust projects.

### Gaps
- I did not find primary coverage of ESWC 2026, SEMANTiCS 2025/2026 or Knowledge Graph Conference 2026 tool tracks naming new triplestores; the only conference-linked item is the ISWC 2025 Wikidata Workshop benchmark and Tentris's ISWC 2025 paper.
- No funding/commercial announcement for QLever beyond the NGI Search grant was found (searches for "QLever funding" return unrelated companies).
- Whether Wikimedia has chosen a final WDQS engine is not stated in the sources found.

## Key question 4: Which have GeoSPARQL, full-text search, reasoning and SHACL built in?

### Takeaway
Only the Java stacks (Jena/Fuseki, RDF4J, GraphDB, Corese) and the proprietary engines cover all four; QLever and Oxigraph cover spatial and (QLever) text but have no built-in reasoning or SHACL; Virtuoso has native full-text and limited RDFS/OWL inference but no SHACL. For GeoSPARQL on a dev machine, Jena's GeoSPARQL assembler (OGC GeoSPARQL 1.0, six conformance classes) is the most complete open option.

### Cited Findings (comparison table)

| Store | GeoSPARQL | Full-text search | Reasoning | SHACL | Source |
|---|---|---|---|---|---|
| Jena / Fuseki | OGC GeoSPARQL 1.0 (11-052r4), six conformance classes incl. Query Rewrite; `jena-fuseki-geosparql` standalone server or GeoSPARQL assembler + Fuseki Mod for spatial index | jena-text (Lucene) index (well-known module; not re-verified here) | Rule engine, RDFS/OWL (project page lists Inference API) | jena-shacl (not re-verified) | [Jena GeoSPARQL docs](https://jena.apache.org/documentation/geosparql/), [jena.apache.org](https://jena.apache.org/) |
| RDF4J | Partial, via `rdf4j-queryalgebra-geosparql` (Spatial4J/JTS), WKT only by default; spatial indexing through Lucene/Elasticsearch SAIL; Solr SAIL removed in 6.0 | Lucene SAIL (Lucene 10 in 6.0) | RDFS (SchemaCachingRDFSInferencer; not re-verified) | ShaclSail (repo topic "shacl") | [RDF4J GeoSPARQL docs](https://rdf4j.org/documentation/programming/geosparql/), [6.0.0 notes](https://rdf4j.org/release-notes/6.0.0), [GitHub topics](https://github.com/eclipse-rdf4j/rdf4j) |
| QLever | Spatial: `SpatialJoin` with bounding boxes, `ql:envelope*`, `ql:simplifyGeometry`; docs page "GeoSPARQL support" | Native text index (`ql:contains-word`/`ql:contains-entity`, `ql:has-word`); docs page "Text search" | None documented | None documented | [QLever releases](https://github.com/ad-freiburg/qlever/releases), [docs nav](https://docs.qlever.dev/) |
| Oxigraph | Partial GeoSPARQL via `spargeo`; "significant set" of new functions in 0.5.8 | None documented | None | None | [README](https://github.com/oxigraph/oxigraph), [Releases](https://github.com/oxigraph/oxigraph/releases) |
| Virtuoso OSE | Geometry/geo functions exist; GeoSPARQL compliance not mentioned in 7.2.16 notes | Native `bif:contains` text index (not re-verified) | Backward-chained RDFS/OWL subset via inference rules (not re-verified) | None | [7.2.16 notes](https://community.openlinksw.com/t/virtuoso-open-source-7-2-16-release-notes/5951) |
| GraphDB (free mode) | GeoSPARQL plugin (not re-verified) | Lucene/Elasticsearch/OpenSearch connectors, vector search added in 11.2.0 ("available connectors" limited in Free) | RDFS/OWL-RL rulesets (not re-verified) | SHACL validation (not re-verified) | [11.2.0 notes](https://help.graphwise.ai/en/graphdb/graphdb-release-notes/graphdb-11-2-0-release-notes.html), [RDFLib docs](https://rdflib.readthedocs.io/en/stable/graphdb/) |
| Corese | Not stated | Not stated | RDFS/OWL reasoning | SHACL validation | [corese-stack](https://github.com/corese-stack) |
| qEndpoint | GeoSPARQL support | Full-text | Via RDF4J stack (not stated) | Not stated | [README](https://github.com/the-qa-company/qEndpoint) |
| MillenniumDB | Not stated | Not stated | None stated | None stated | [README](https://github.com/MillenniumDB/MillenniumDB) |
| Neo4j + n10s | Neo4j spatial (not GeoSPARQL) | Neo4j full-text indexes (not GeoSPARQL/SPARQL) | Ontology inference procedures (n10s 5.7.0.0 added "ontology inference procedures") | SHACL validation (repo description) | [n10s releases](https://github.com/neo4j-labs/neosemantics/releases), [repo](https://github.com/neo4j-labs/neosemantics) |
| Open Triplestore | GeoSPARQL 1.0/1.1 (claimed, not OGC-certified) | Yes (claimed) | OWL 2 RL/EL/QL native, DL via HermiT sidecar (claimed) | SHACL Core + ShEx (claimed) | [README](https://github.com/philipperenzen/open-triplestore) |
| sparq | GeoSPARQL (claimed) | Yes (claimed) | RDFS, OWL 2 RL, N3 (claimed) | SHACL (claimed, CI ratchet) | [README](https://github.com/sparq-org/sparq) |
| Stardog / RDFox / AllegroGraph / AnzoGraph | Proprietary; feature sets not re-verified in this pass | | | | see Q1 sources |

- Community GeoSPARQL-enabled Fuseki images exist: `zazuko/fuseki-geosparql` ("non-official Fuseki Docker image with GeoSPARQL support") and `aksw/fuseki-coypu` ("GeoSPARQL preconfigured"); the official `jena-fuseki-docker` package builds from Maven with SHA1 check but is not GeoSPARQL-specific; `jena-fuseki-geosparql` has "no GUI interface as provided in the Fuseki distribution" — [Jena Fuseki Docker docs](https://jena.apache.org/documentation/fuseki2/fuseki-docker.html), [Jena GeoSPARQL Fuseki](https://svn.apache.org/repos/infra/websites/production/jena/content/documentation/geosparql/geosparql-fuseki.html)

### Inferences
- If the stack wants GeoSPARQL without adding a new engine, the cheapest path is a second Fuseki service configured with the GeoSPARQL assembler (or the `zazuko/fuseki-geosparql` image), since Fuseki is already present; QLever's spatial joins cover bounding-box/distance workloads but not the OGC conformance classes.
- SHACL + reasoning for free with an official image means GraphDB free mode, RDF4J Server (ShaclSail), or Corese; of these only GraphDB and RDF4J have verified Docker images.

### Gaps
- Several "(not re-verified)" cells rely on general knowledge of long-standing modules (jena-text, jena-shacl, Virtuoso bif:contains, GraphDB rulesets/SHACL/GeoSPARQL plugin, RDF4J RDFS inferencer); their current docs pages were not fetched in this pass.
- QLever's "GeoSPARQL support" and "Text search" docs pages were listed in navigation but their contents could not be fetched (text-search page returned 404 at the guessed URL).
- Proprietary engines' feature matrices (Stardog, RDFox, AnzoGraph) were not researched because they lack a free self-hosted tier (Stardog, RDFox) or current docs (AnzoGraph).
