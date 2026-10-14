# RDF mapping, ETL/pipeline, validation, reasoning and virtual-KG tools for a Docker Compose semantic stack (state as of 2026-10-14)

Scope note: the stack already has QLever, Fuseki, Oxigraph, RDF4J Workbench, OntoRefine/OpenRefine, rmlmapper-java (v7.3.3), a YARRRML parser, WebVOWL, Trifid, Blueprint, YASGUI, Comunica and Zazuko SHACL Playground. Those are not re-recommended below, but version drift on the ones already present (rmlmapper, yarrrml-parser) is flagged. Dates are taken from GitHub release feeds / Docker Hub tag timestamps retrieved on 2026-10-14; "GitHub `updated_at`" is the repo's last-activity timestamp from the GitHub search API and is a weaker signal than a dated release.

Method caveat: the session's GitHub API access was restricted to the target repo, so star counts and `updated_at` come from the GitHub search API (which did work), release dates from each repo's `releases.atom` feed, and image dates from the Docker Hub v2 tags API. Where a release page showed no year and no feed was fetched, the year is marked unverified.

## Key Question 1: Mapping engines (RML new-spec implementations, BURP, Ontop/OBDA, SPARQL Anything, TARQL, CSVW, JSON-LD, XML, LinkML, OpenRefine RDF extension, YARRRML tooling, Mapeathor, Dragoman)

### Takeaway
The strongest additions for mapping are (a) Ontop 5.5.0 (official `ontop/ontop` image, Feb 2026) for virtual KGs over SQL, (b) SPARQL Anything 1.3.0-RC2 (`facadex/sparql-anything`, Oct 2026) for query-anything/Facade-X, and (c) at least one new-RML-spec-conformant engine; the KGCW 2026 challenge shows CARML (dev `rml-cg` branch) and SDM-RDFizer at 100% on all five tested RML modules and BURP-Error at 100%/95.89%, while the already-installed rmlmapper-java is at v8.1.0 (Dec 2025, Java 21) but only ~90%/65% on RML-Core/RML-IO per the 2025 challenge. Morph-KGC remains the most feature-rich Python engine (2.10.0, Jan 2026, Jelly output, HTTP sources) but its Docker Hub image is stale (v2.2.0, Apr 2024) so you must build the image yourself.

### Cited Findings

**Already-present engines: version drift**
- rmlmapper-java: v8.1.0 published 23 Dec 2025 (adds crossConcat functions, requires Java >= 21, moved publishing to Maven Central); v8.0.1 on 11 Dec 2025 (Jena 5.2.0, security bumps) — [Zenodo v8.1.0](https://zenodo.org/records/18032528); [Zenodo v8.0.1](https://zenodo.org/records/17899553). Docker Hub `rmlio/rmlmapper-java` newest tags: v8.0.1 (2025-12-11), v8.0.0 (2025-09-18), v7.3.3 (2025-04-07); no v8.1.0 image tag seen on the first page — [Docker Hub tags](https://hub.docker.com/r/rmlio/rmlmapper-java/tags). Repo: 206 stars, MIT, last push 2026-02-17 — [GitHub](https://github.com/RMLio/rmlmapper-java).
- New-spec coverage of RMLMapper: a KGCW 2025 paper reports RMLMapper "largely supports RML-Core and RML-IO (90% and 65%)" and that the authors cannot claim full coverage of the RMLkgc spec — [CEUR Vol-3999 short2](https://ceur-ws.org/Vol-3999/short2.pdf).
- yarrrml-parser: v1.12.2 (2025-10-22), v1.12.1 (2025-09-22, `type: blank` subjects), v1.12.0 (2025-08-27, HTTP request targets now use `htv:headers` instead of deprecated `rmle:contentType`) — [releases.atom](https://github.com/RMLio/yarrrml-parser/releases.atom). Docker Hub `rmlio/yarrrml-parser` newest tag 1.11.0 (2025-07-10); `latest` points at 1.10.0 (2025-03-11) — [Docker Hub](https://hub.docker.com/r/rmlio/yarrrml-parser/tags). 58 stars — [GitHub](https://github.com/RMLio/yarrrml-parser).
- Matey (web YARRRML editor, RMLio): 9 stars, JS, GitHub `updated_at` 2026-10-04; no Docker image found — [GitHub](https://github.com/RMLio/matey).

**New RML spec status**
- The W3C KG Construction CG is "moving forward with the transition from the KG Construction CG to a W3C Working Group, with the goal of advancing RML towards a W3C Recommendation" (Jan 2026 call for interest, draft charter linked) — [public-kg-construct Jan 2026](https://lists.w3.org/Archives/Public/public-kg-construct/2026Jan/0001.html). RML-Core spec at w3id.org/rml/core/spec, CC-BY-SA 4.0; no "final"/Recommendation version found — [search summary, CEUR Vol-3999 short2](https://ceur-ws.org/Vol-3999/short2.pdf).
- KGCW 2026 challenge (4th edition, KGCW'26 at ESWC, Dubrovnik, 10 May 2026; CEUR Vol-4245 paper16, published 2026-08-24). Track 1 conformance results (RML-Core / RML-IO / RML-CC / RML-FNML / RML-LV): BURP-Error 100/95.89/100/100/100; Typhon-RML 86.84/86.30/0/0/0; CARML 100/100/100/100/100; MappingWeaver with RMLViewer 92.10/28.76/0/78.94/100; SDM-RDFizer 100/100/100/100/100. Five engines in conformance, three in performance (SDM-RDFizer, CARML, CARML-reactive); CARML variants were faster/lower CPU than SDM-RDFizer in 3 of 4 scenarios — [CEUR Vol-4245 paper16](https://ceur-ws.org/Vol-4245/paper16.pdf). The CARML version used was "the development build on the rml-cg branch" — [CARML rml-cg branch](https://github.com/carml/carml/tree/rml-cg). SDM-RDFizer version used: 4.7.5.14 (same source).
- KGCW 2025 (3rd edition, ESWC 2025, Portorož, 1 Jun 2025) tested RML-Core, RML-IO, RML-IO-Registry, RML-CC, RML-FNML, RML-Star, RML-LV — [CEUR Vol-3999](https://ceur-ws.org/Vol-3999/); [workshop site](https://w3id.org/kg-construct/workshop).

**BURP (reference implementation)**
- BURP = "Basic and Unassuming RML Processor", the KG-Construct CG's from-scratch reference implementation; MIT; Java (parts rewritten in Kotlin); 7 stars; last push 2026-09-09 — [GitHub](https://github.com/kg-construct/BURP); [BURP paper, KGCW 2024](https://ceur-ws.org/Vol-3718/paper11.pdf). Coverage matrix on README: RML-Core 76/76, RML-IO 56/56, RML-IO-Registry 52/102 (in progress), RML-CC 35/35, RML-FNML 20/20, RML-LV 41/41, RML-Star not implemented — [GitHub README](https://github.com/kg-construct/BURP).
- Run: `jbang burp@kg-construct -m mapping.ttl [-o out] [-b baseIRI]` or `java -jar burp.jar`; build needs a GitHub token in Maven `settings.xml` because some deps come from GitHub's Maven registry; Docker is only used for MySQL/Postgres tests; no Dockerfile/image — [GitHub README](https://github.com/kg-construct/BURP).
- Latest Zenodo version v0.1.3, published 14 Aug 2026 — [Zenodo concept DOI](https://zenodo.org/doi/10.5281/zenodo.11037711). The RML-LV implementation lives on branch `kgc-2025-conformance`; BURP-Error (adds RML Execution Report error handling) is a fork at jduchateau/BURP-Errors — [CEUR Vol-4245 paper16](https://ceur-ws.org/Vol-4245/paper16.pdf).

**Morph-KGC**
- Apache-2.0, Python, 296 stars, last push 2026-10-06 — [GitHub](https://github.com/morph-kgc/morph-kgc). Releases: 2.10.0 (2026-01-20: HTTP API request sources with dynamic token resolution, Jelly-RDF output, Snowflake, GeoParquet/shapefile sources, env vars in credentials, RML-FNML null fix), 2.9.0 (2026-01-12), 2.9.0-beta.1 (2025-08-26) — [releases.atom](https://github.com/morph-kgc/morph-kgc/releases.atom); [releases page](https://github.com/morph-kgc/morph-kgc/releases).
- Install `pip install morph-kgc[all]`; extras for mysql/postgresql/mssql/oracle/sqlite/neo4j/snowflake/databricks/excel/tabular/spss/geoparquet/jelly; sources: RDBs, tabular (CSV/TSV/Excel/Parquet/Feather/ORC/Stata/SAS/SPSS/ODS), GeoParquet/Shapefile, XML (XPath), JSON (JSONPath), in-memory DataFrames; outputs N-Triples (default), N-Quads, Jelly (held fully in memory). Docker: build locally with `docker build -t morph-kgc . --build-arg optional_dependencies="sqlite,jelly"` then `docker run -v $(pwd)/files:/app/files morph-kgc files/config.ini` — [Morph-KGC docs](https://morph-kgc.readthedocs.io/en/latest/documentation/).
- Docker Hub `kgconstruct/morph-kgc` latest tag v2.2.0, last updated 2024-04-16 (stale vs PyPI 2.10.0) — [Docker Hub tags](https://hub.docker.com/r/kgconstruct/morph-kgc/tags).
- Gotcha from the 2025 RML-CC tooling paper: BURP passes all RML-CC test cases while Morph-KGC passes only 51% — [search summary citing citius.gal publication](https://citius.gal/research/publications/declarative-generation-of-rdf-collections-and-containers-from-heterogeneous-data/).

**SDM-RDFizer**
- Apache-2.0, Python, 140 stars, last push 2026-09-25 — [GitHub](https://github.com/SDM-TIB/SDM-RDFizer). Releases v4.7.5.15.4.1 (2026-09-25), v4.7.5.15.4 (2026-09-25), v4.7.5.15.3 (2026-09-16); release notes are one-line bug fixes — [releases.atom](https://github.com/SDM-TIB/SDM-RDFizer/releases.atom). Docker Hub `sdmtib/sdmrdfizer`: tag 4.7.5.15.2 and `latest` updated 2026-09-10 — [Docker Hub tags](https://hub.docker.com/r/sdmtib/sdmrdfizer/tags). 100% on all five KGCW 2026 conformance modules; supports compressed inputs (ZIP, TAR) since 2024/2025 challenges — [CEUR Vol-4245 paper16](https://ceur-ws.org/Vol-4245/paper16.pdf).

**CARML**
- MIT, Java, RDF4J + Project Reactor, 114 stars, last push 2026-08-31; maintained by Skemu (originally Taxonic/Kadaster); CLI via separate `carml-jar` project; FnO functions via `fnml:FunctionMap`; no Docker image mentioned — [GitHub](https://github.com/carml/carml). Releases v0.4.13 and v0.4.12 (both 2025-11-13), v0.4.11 (2024-10-04) — [releases.atom](https://github.com/carml/carml/releases.atom). carml-jar releases: v1.4.0 (2024-10-05), v1.3.0 (2023-09-08) — [carml-jar releases.atom](https://github.com/carml/carml-jar/releases.atom). The 100%-conformant build is the unreleased `rml-cg` branch — [CEUR Vol-4245 paper16](https://ceur-ws.org/Vol-4245/paper16.pdf).

**RMLStreamer**
- MIT, Scala/Flink, 63 stars, last push 2024-02-21 (inactive ~2.5 years) — [GitHub](https://github.com/RMLio/RMLStreamer).

**PyRML**
- Apache-2.0, Python, 52 stars, GitHub `updated_at` 2026-10-05; `pip install pyrml-lib`; CLI `pyrml-mapper.py -o out -f turtle -m` (multiprocessing); RML spec coverage not documented; no Docker; Releases tab empty — [GitHub](https://github.com/anuzzolese/pyrml). May 2025 arXiv paper claims lower execution times/variance than RMLMapper — [arXiv 2505.20949](https://arxiv.org/pdf/2505.20949).

**Typhon-RML (Cefriel)** — appeared in KGCW 2026 at v0.3 with 86.84%/86.30% on RML-Core/RML-IO and 0% on CC/FNML/LV — [CEUR Vol-4245 paper16](https://ceur-ws.org/Vol-4245/paper16.pdf); repo [cefriel/typhon-rml](https://github.com/cefriel/typhon-rml) (not fetched; details unverified).

**Ontop (virtual KG / OBDA over SQL)**
- Apache-2.0, Java, 976 stars, last push 2026-09-21, default branch `version5` — [GitHub](https://github.com/ontop/ontop). Releases: 5.5.0 (14 Feb 2026: file/directory paths as relation names in mapping FROM clauses, CTE support in SQL serialization, time-interval ops, `obdaf:queryId`, DuckDB 1.4 metadata), 5.4.0 (29 Sep 2025: two-phase query unfolder, `rdfs:subClassOf*` path, TDEngine, bottom-up EXISTS, multi-line target queries), 5.3.1 (29 Sep 2025), 5.3.0 (18 Feb 2025: RDF4J 5.1.0, OWLAPI 5.5.1) — [ontop-vkg.org releases](https://ontop-vkg.org/guide/releases.html); [GitHub releases](https://github.com/ontop/ontop/releases). Java 11+ required since 5.0.0 (same source).
- Official Docker image `ontop/ontop`: tags `latest`/5.5.0 (2026-02-14), 5.3.1 (2025-09-29), 5.4.0 (2025-09-28) — [Docker Hub tags](https://hub.docker.com/r/ontop/ontop/tags). (Endpoint port: Ontop's SPARQL endpoint conventionally listens on 8080 inside the container; not re-verified this session.)
- Ontop-based commercial tooling: Ontopic (Free University of Bozen-Bolzano spin-off) sells "Ontopic Studio", a no-code mapping editor; proprietary — [ontop-vkg.org organizations](https://ontop-vkg.org/community/organizations.html); [Ontopic docs](https://docs.ontopic.ai/suite/administrate/jdbc-drivers.html).
- D2RQ: status unknown, last release 0.8.1; d2rq.org was already unresponsive in 2017; no named successor found (Ontop is the de-facto replacement) — [ConfIDent D2RQ entry](https://confident.dbis.rwth-aachen.de/or/index.php?title=D2RQ); [W3C list 2017](https://lists.w3.org/Archives/Public/semantic-web/2017Jun/0033.html).

**SPARQL Anything (Facade-X)**
- Apache-2.0, Java 21+, 307 stars, last push 2026-10-13 — [GitHub](https://github.com/SPARQL-Anything/sparql.anything). Releases v1.3.0-RC2 and RC1 (both 8 Oct 2026; aligns with W3C Data Façades CG v0.1 specs, engine options move to `fxe:` namespace, `fx:root` deprecated for `fx:Root`), nightly `snapshot-20261013-085821` — [releases page](https://github.com/SPARQL-Anything/sparql.anything/releases). Docker Hub `facadex/sparql-anything`: `latest`/v1.3.0-RC2 (2026-10-08), v1.2.0 (2026-07-24), v1.1.0 (2025-12-17); 36 tags — [Docker Hub tags](https://hub.docker.com/r/facadex/sparql-anything/tags). Server is "via Jena Fuseki" (CLI, library and web server modes) — [sparql-anything.cc](https://sparql-anything.cc/). Default server port not confirmed in fetched pages (the project's docs/README server section historically documents port 3000; unverified this session).

**TARQL**
- 207 stars, Java/Jena; last release v1.2 on 2019-05-03 (Jena 3.11); v1.1 2016 — [releases.atom](https://github.com/tarql/tarql/releases.atom); [GitHub](https://github.com/tarql/tarql). GitHub `updated_at` 2026-09-21 (likely stars/forks, not code). No official Docker image found. RPT (see Q2) includes an RML-to-SPARQL/TARQL converter, which partially overlaps.

**CSVW tooling**
- W3C `w3c/csvw` repo is archived (spec docs) — [GitHub](https://github.com/w3c/csvw). Swirrl `csv2rdf` (Clojure, W3C CSVW implementation, 31 stars): releases v0.7.1/v0.7.0 on 2024-01-31; Docker images in Google Artifact Registry `europe-west2-docker.pkg.dev/swirrl-devops-infrastructure-1/public/csv2rdf:v0.7`, run with `-v .:/data ... -t /data/input.csv -o /data/output.ttl` — [releases.atom](https://github.com/Swirrl/csv2rdf/releases.atom); [cljdoc README](https://cljdoc.org/d/swirrl/csv2rdf/0.7.1/doc/readme). CoW (`cow-csvw`, Python): `cow_tool_cli build file.csv` then `cow_tool_cli convert file.csv` (N-Quads default) — [PyPI](https://pypi.org/project/cow-csvw/). `ruby-rdf/rdf-tabular` (21 stars, Ruby; GitHub `updated_at` 2026-06-12) — [GitHub](https://github.com/ruby-rdf/rdf-tabular). `atomgraph/csv2rdf` is a different SPARQL-CONSTRUCT-per-row tool, Docker Hub updated >5 years ago — [Docker Hub](https://hub.docker.com/r/atomgraph/csv2rdf). barnard59 also has a `barnard59-csvw` package (see Q2).

**JSON-LD framing CLI**
- `digitalbazaar/jsonld-cli` (62 stars, JS, GitHub `updated_at` 2026-08-30) — [GitHub](https://github.com/digitalbazaar/jsonld-cli). No release dates or Docker image verified; JSON-LD 1.1 framing spec at [w3c.github.io/json-ld-framing](https://w3c.github.io/json-ld-framing/).

**XML to RDF**
- SPARQL-Generate (Jena-based, extends SPARQL 1.1 to generate RDF from XML/CSV/JSON; modules include `sparql-generate-binary`, `-server`, `-website`): 71 stars, 575 commits, GitHub `updated_at` 2026-08-13; Releases section empty; license not shown on page — [GitHub](https://github.com/sparql-generate/sparql-generate). XSPARQL is a 2008-era W3C Member Submission with no 2025 activity found — [W3C submission](https://www.w3.org/submissions/xsparql-language-specification/). RML itself covers XML via XPath (Morph-KGC, rmlmapper, CARML), and RPT/JenaX offers SPARQL functions over XML.

**LinkML**
- 651 stars, Python; releases v1.12.1 (13 Oct 2026, year inferred from Docker Hub), v1.12.0 (8 Oct 2026: new `gen-openapi`, RDF output canonicalised with RDFC-1.0, `--no-generation-date` for reproducible output, JSON Schema closed classes), v1.12.0-rc2 — [releases page](https://github.com/linkml/linkml/releases); [GitHub](https://github.com/linkml/linkml). Official Docker image `linkml/linkml`: tags `latest`/1.12/1.12.1 (2026-10-13), 1.12.0 (2026-10-08); 103 tags — [Docker Hub tags](https://hub.docker.com/r/linkml/linkml/tags). LinkML generates SHACL/ShEx/OWL/JSON-Schema from one YAML schema (repo topics include shacl, shex, owl, json-ld-context) — [GitHub](https://github.com/linkml/linkml).

**OpenRefine RDF extension (RDF Transform)**
- AtesComp/rdf-transform, 40 stars, Java; releases 2.3.6 (2025-09-22, "production ready", Lucene IRI search), 2.3.5 (2025-09-14), 2.3.4 (2025-09-08); older notes reference OpenRefine 3.8+ — [releases.atom](https://github.com/AtesComp/rdf-transform/releases.atom); [releases page](https://github.com/AtesComp/rdf-transform/releases). Installs as an extension into the existing OpenRefine container (not a separate service).

**Mapeathor**
- oeg-upm/mapeathor (spreadsheet -> R2RML/RML/YARRRML), 33 stars, Python; last release v1.7.5 on 2024-05-12; GitHub `updated_at` 2026-02-10 — [releases.atom](https://github.com/oeg-upm/mapeathor/releases.atom); [GitHub](https://github.com/oeg-upm/mapeathor).

**Dragoman** — no GitHub repository found via code search for "dragoman rml function"; see Gaps.

**MappingWeaver / RMLViewer** — participated in KGCW 2026 (92.10% Core, 28.76% IO, 0% CC, 78.94% FNML, 100% LV) — [CEUR Vol-4245 paper16](https://ceur-ws.org/Vol-4245/paper16.pdf); repo URL not captured.

### Inferences
- For a "new RML spec" engine in the stack, the pragmatic choices are SDM-RDFizer (published Docker image, 100% conformance, pip-installable) or CARML (JVM, MIT, 100% on the unreleased `rml-cg` branch; the released 0.4.x/carml-jar 1.4.0 are older). BURP is the reference, but needs jbang/Maven with a GitHub token and has no image; good as a one-shot "spec oracle" container built from source.
- Morph-KGC's stale Docker Hub image means a local `Dockerfile` build (or `python:3.x` base + `pip install morph-kgc[all]`) is required; its Jelly output pairs with Jelly plugins for Fuseki/RDF4J (Q2).
- Upgrading rmlmapper-java from 7.3.3 to 8.x implies a Java 21 base image (v8.1.0) and the Docker Hub tag lags one release behind Zenodo/Maven Central.
- Ontop is the only mature open-source OBDA option; its official image is current (Feb 2026) and it fits a compose stack directly (needs a JDBC driver + `.obda`/R2RML mapping + ontology mounted).
- SPARQL Anything is release-active (two RCs in Oct 2026) and complements RML for ad-hoc "query a JSON/CSV/HTML file as RDF" use cases; the Fuseki-based server can be exposed as another SPARQL endpoint in YASGUI.
- TARQL is stable but effectively frozen since 2019; RPT's TARQL/RML-to-SPARQL capability or SPARQL Anything cover the same niche with active maintenance.

### Gaps
- Could not verify a GitHub repo, license or Docker artifacts for "Dragoman"; GitHub repository search returned no results.
- SPARQL Anything server default port and Docker run flags were not present on the pages fetched (project site, README, readthedocs 404); check `docs/README.md` server section and `docs/BROWSER.md` in the repo.
- Ontop's Docker container port and the exact `ontop endpoint` invocation were not re-verified this session.
- No per-engine results for the KGCW 2025 (3rd edition) challenge were retrieved; only the 2026 (4th edition) table was extracted.
- RMLtoSHACL (RMLio) repo could not be located via the GitHub search API (it did not appear in a `repo:RMLio/RMLtoSHACL` query); existence/activity unverified.
- MappingWeaver/RMLViewer and Typhon-RML repos were not inspected for license/Docker.
- SPARQL-Generate license and last release not visible on the fetched page.

## Key Question 2: Pipeline / ETL orchestration specific to RDF (barnard59, cube-creator, RPT, LinkedPipes ETL, UnifiedViews, Silk, LIMES, NiFi, Databus, kglab, RDF-Connect, Jelly, RDF Delta, DCAT catalogs)

### Takeaway
Three orchestration-style tools are both active and container-ready: Zazuko barnard59 (npm CLI, 5.1.6 Aug 2026), AKSW RDF Processing Toolkit (`aksw/rpt:2.0.0-rc7`, Jul 2026, built-in SPARQL/GraphQL server on 7531) and LinkedPipes ETL (`ghcr.io/linkedpipes/etl-*` compose, frontend on 8080, develop branch active though no GitHub release since Jan 2024). Jelly (binary RDF streaming; Fuseki/RDF4J drop-in plugins, CLI, Python) is the notable 2025-2026 newcomer for moving data between stack components; Silk and LIMES still work for interlinking but their published images date from 2022/2024; UnifiedViews, RDFStreamer-style streaming and RDF Delta are effectively dormant.

### Cited Findings

**barnard59 (Zazuko)**
- Monorepo "RDF pipeline solution ... to automate ETL processes"; 40 stars, JS/Node, GitHub `updated_at` 2026-10-08; packages: `barnard59` CLI, `-shacl`, `-formats`, `-sparql`, `-cube`, `-csvw`, `-graph-store`, `-http`, `-rdf`, `-s3`, `-ftp`, `-n3`, `-validation`; ~1,629 commits — [GitHub](https://github.com/zazuko/barnard59). Latest releases barnard59@5.1.6, barnard59-http@2.1.1, barnard59-formats@4.0.2 (all 2026-08-05) — [releases.atom](https://github.com/zazuko/barnard59/releases.atom). No Docker image mentioned on the repo page (run via `npx barnard59` in a Node container).

**cube-creator (Zazuko)**
- CSV -> RDF Data Cube app (TypeScript); 16 stars, 98 open issues; last releases cube-creator-cli/v4.1.1, -app/v1.15.0, -api/v2.4.2 all 2025-02-24; GitHub `updated_at` 2026-03-11 — [releases.atom](https://github.com/zazuko/cube-creator/releases.atom); [GitHub](https://github.com/zazuko/cube-creator).

**RDF Processing Toolkit (RPT, AKSW / Scaseco)**
- Apache-2.0, Java; CLI to run SPARQL statement sequences over datasets, binding streams and named-graph streams; JSON/CSV/XML via JenaX function extensions; embeds Jena ARQ/TDB, "supports qlever", Spark batch engine; integrated SPARQL + GraphQL server; RML toolkit that converts RML to SPARQL or TARQL; 51 stars — [GitHub](https://github.com/Scaseco/RdfProcessingToolkit). Docker: `docker run -p 7531:7531 -it aksw/rpt integrate --server` — same source. Releases v2.0.0-rc7 (2026-07-28: `rpt-integrate-await` wrapper, `norse:fs.find` fix), rc6 (2026-03-28: Jena 6.1.0-SNAPSHOT, YASGUI integration with geo viewer, `urn:mvn:` artifact resolution; note "broken dependencies affecting tdb2 integration"), rc5 (2025-08-11) — [releases.atom](https://github.com/Scaseco/RdfProcessingToolkit/releases.atom); [releases page](https://github.com/Scaseco/RdfProcessingToolkit/releases). Docker Hub `aksw/rpt`: 2.0.0-rc7 (2026-07-01), `latest`=rc6 (2026-03-11) — [Docker Hub tags](https://hub.docker.com/r/aksw/rpt/tags).

**LinkedPipes ETL**
- "RDF based, lightweight ETL tool"; 162 stars, Java, 200 open issues, ~2,662 commits on `develop`; `docker compose up` pulls prebuilt images from GitHub Packages; env `LP_VERSION` (default `main`), `LP_ETL_PORT`, `LP_ETL_DOMAIN`; Java 21-26 only for local builds — [GitHub](https://github.com/linkedpipes/etl). Compose services/images: `ghcr.io/linkedpipes/etl-storage`, `etl-frontend` (published `${LP_ETL_PORT-8080}:8080`), `etl-executor-monitor`, `etl-executor`, all `:${LP_VERSION-main}` — [docker-compose.yml](https://raw.githubusercontent.com/linkedpipes/etl/develop/docker-compose.yml). Only two GitHub releases exist (2024-01-08 "ghcr.io is the main repository", 2022-12-16) — [releases page](https://github.com/linkedpipes/etl/releases); GitHub `updated_at` 2026-10-01. Docker Hub `linkedpipes/etl` returns 404 (images are on GHCR only) — [Docker Hub v2 check](https://hub.docker.com/v2/repositories/linkedpipes/etl/tags).

**UnifiedViews**
- GitHub org `UnifiedViews` now exposes only `Packages` (updated 2017) and `Maven-Repo` (2015); the `Core` repo was not found via the search API — [org search result](https://github.com/UnifiedViews). Tool paper is 2018 (SWJ); GPLv3/LGPLv3 — [Semantic Web Journal](https://www.semantic-web-journal.net/content/unifiedviews-etl-tool-rdf-data-management-0). Treat as dead.

**Silk link discovery**
- 252 stars, Scala, ~18,900 commits on `develop`, GitHub `updated_at` 2026-10-12 — [GitHub](https://github.com/silk-framework/silk). Docker: `docker run -d -p 80:80 silkworkbench/silk-framework:latest`, workspace volume `/opt/silk/workspace`, config at `/opt/config/production.conf`; local build needs JDK 21, sbt, Yarn, Node 20+ — same source. Last GitHub releases v3.6.0 (2021-11-19), v3.5.0 (2021-05-10) — [releases.atom](https://github.com/silk-framework/silk/releases.atom). Docker Hub `silkworkbench/silk-framework`: `latest` 2022-11-10, `v3.8.0-rc1` 2022-12-16 — [Docker Hub tags](https://hub.docker.com/r/silkworkbench/silk-framework/tags). License not shown on fetched page.

**LIMES link discovery**
- AGPL-3.0, Java, 133 stars; Docker `dicegroup/limes:latest`, CLI mode mounts `/data` and takes an XML config; server mode `docker run -p 8080:8080 dicegroup/limes:latest -s`; `limes-web-ui` folder; Maven `org.aksw.limes:limes-core` — [GitHub](https://github.com/dice-group/LIMES). Releases 1.8.3 (2024-08-14), 1.8.2 (2024-08-07), 1.8.1 (2024-06-11) — [releases.atom](https://github.com/dice-group/LIMES/releases.atom). Docker Hub tags 1.8.3/`latest` 2024-08-14 — [Docker Hub tags](https://hub.docker.com/r/dicegroup/limes/tags). GitHub `updated_at` 2026-10-12.

**DBpedia Databus**
- "digital factory platform for managing files online with stable IDs"; 74 stars, JS, 101 open issues; releases "Merged 2.1.4 from dev" (2026-09-25), 2.1.3 (2026-09-24) — [releases.atom](https://github.com/dbpedia/databus/releases.atom); [GitHub](https://github.com/dbpedia/databus). (Compose deployment exists per project docs; not fetched.)

**kglab**
- 695 stars, Python abstraction layer over RDFlib/pySHACL/morph-kgc/NetworkX etc.; GitHub `updated_at` 2026-10-12 — [GitHub](https://github.com/DerwenAI/kglab). A library, not a service; release cadence not verified.

**RDF-Connect (IDLab)**
- Declarative, cross-language streaming pipeline framework (JS + JVM runners, Python planned at time of paper) — [SOFLIM2KG-SEMIIM 2024 paper](https://ceur-ws.org/Vol-3830/paper1.pdf). Org has 60 repos; `js-runner` ("run workflows from the command line, in Docker, or in CI/CD"), `orchestrator-js`, processors `shacl-processor-ts`, `rml-utils-processor-ts` (wraps RMLMapper), `http-utils-processor-ts`, `file-utils-processors-ts`, `ldes-client`, `ldes-server`, `sds-storage-writer-ts`; most updated 13-14 Oct 2026 — [GitHub org](https://github.com/rdf-connect). Kotlin `orchestrator` repo: 2 stars, last update 2025-02-18 (superseded by orchestrator-js) — [GitHub](https://github.com/rdf-connect/orchestrator). Python runner `rdfc-runner` on PyPI — [PyPI](https://pypi.org/project/rdfc-runner/). A half-day RDF-Connect tutorial was given at SEMANTiCS 2025 (Vienna, 3 Sep 2025) — [search summary; LinkedIn profile of Ieben Smessaert](https://be.linkedin.com/in/ieben-smessaert).

**Jelly (binary RDF streaming format)**
- Paper (June 2025): open protocol spec, Java and Python implementations, CLI — [arXiv 2506.11298](https://arxiv.org/abs/2506.11298). Jelly-JVM: Apache-2.0, Scala, 54 stars, covers Jena, RDF4J, Titanium, Neo4j; plugin JARs usable "just by dropping the JARs into the classpath"; commercial support by NeverBlink, EU funding — [GitHub](https://github.com/Jelly-RDF/jelly-jvm). Releases v3.7.3 (2026-05-20: Pekko, rdf4j 5.3.1), v3.7.2 (2026-03-28), v3.7.1 (2026-02-23); v3.7.0 added Jena 6 support — [releases.atom](https://github.com/Jelly-RDF/jelly-jvm/releases.atom); [releases page](https://github.com/Jelly-RDF/jelly-jvm/releases). Fuseki: drop `jelly-jena-plugin.jar` into `$FUSEKI_BASE/extra/`; content negotiation with `Accept: application/x-jelly-rdf` works from Jena 5.2.0; RDF4J: `jelly-rdf4j-plugin.jar` into `lib/` — [Jelly plugins guide](https://jelly-rdf.github.io/jelly-jvm/dev/getting-started-plugins/). jelly-cli: v0.10.0 (2026-07-22, JDK 21 minimum, Jelly-JVM 3.7.1), v0.9.0 (2026-02-08, `--merge-graphs`), v0.8.4 (2026-01-23); commands transcode/inspect/validate — [releases.atom](https://github.com/Jelly-RDF/cli/releases.atom); [GitHub](https://github.com/Jelly-RDF/cli). pyjelly: 20 stars, releases v1.0.1 (2026-01-23), v1.0.0 (2026-01-17), v0.7.0 (2025-08-20) — [releases.atom](https://github.com/Jelly-RDF/pyjelly/releases.atom). Consumers already in this list: Morph-KGC 2.10.0 (Jelly output), TopQuadrant SHACL 1.5.0 (Jelly I/O).

**RDF Delta (Jena change propagation)**
- 92 stars, Java; last releases 1.1.2 (2022-08-17), 1.1.1 (2022-05-10), 1.1.0 (2021-12-19, Jena 4.3.2) — [releases.atom](https://github.com/afs/rdf-delta/releases.atom); GitHub `updated_at` 2026-09-01. No Docker image mentioned on releases page.

**SANSA (Spark RDF)**
- 150 stars; last release v0.9.5 (2024-04-18) — [releases.atom](https://github.com/SANSA-Stack/SANSA-Stack/releases.atom). Heavy (Spark); not a fit for a developer-machine compose stack.

**Apache NiFi RDF processors** — no results found in search; see Gaps.

**Other practitioner signals**
- A 2022 W3C list thread proposed an "RDF-LAMP" FOSS list on `w3c/EasierRDF` ("very meager so far") — [W3C semantic-web list, Sep 2022](https://lists.w3.org/Archives/Public/semantic-web/2022Sep/0047.html). No 2025-2026 Reddit threads or LinkedIn posts describing a concrete RDF ETL Docker stack were returned by search.

### Inferences
- barnard59 + RPT cover scripted/declarative pipelines (Node vs JVM); LinkedPipes adds a GUI pipeline designer at the cost of four containers. For a developer stack, RPT is the smallest addition with the most overlap (SPARQL-based ETL, RML->SPARQL, server for YASGUI).
- Jelly is worth adding as plumbing rather than a service: drop the plugin JAR into the existing Fuseki and RDF4J containers and ship `jelly-cli` as a one-shot tool image (needs JDK 21 or the native binary).
- Silk's Docker image is ~4 years behind its `develop` branch; building from source (JDK 21 + sbt + Node 20) is the only way to get current code. LIMES is simpler to run (single jar/image) but last touched Aug 2024.
- UnifiedViews, RDFStreamer, RDF Delta and SANSA should be excluded or listed as "dormant".

### Gaps
- No evidence found of maintained Apache NiFi RDF/SPARQL processors (search returned nothing).
- Silk license and its relationship to eccenca Corporate Memory were not confirmed from fetched pages.
- barnard59 and cube-creator licenses were not shown on the fetched pages (check LICENSE files); no official barnard59 Docker image was confirmed.
- DBpedia Databus compose/ports not fetched.
- kglab release history not fetched.
- Practitioner "what's in my RDF ETL stack" posts on LinkedIn/Reddit for 2025-2026 were not surfaced by search; only academic/tool sources were found.

## Key Question 3: Validation (pySHACL + services, TopBraid SHACL, Jena/RDF4J SHACL, shacl-form/shacl-ui, ShEx tools, RDFUnit, Validatrr, SHACL Play, form generators, SHACL rules, data-quality dashboards)

### Takeaway
pySHACL (0.40.1, Jul 2026) now ships its own OpenAPI HTTP server mode (`PYSHACL_SERVER=TRUE`, port 8099) and Oxigraph backend support, making it the easiest validation service to add; SHACL Play (0.12.5, Oct 2026, LGPL-3.0, Dockerfile, port 8080) adds documentation/UML/JSON-Schema generation and SHACL rules; the EU ITB `isaitb/shacl-validator` (1.13.0, Sep 2026, EUPL) is a production-grade REST/SOAP/web validator; TopQuadrant SHACL 1.5.0 (Mar 2026, Jena 6, Jelly I/O) has a GHCR image for CLI validate/infer; shacl-form (3.7.4, Oct 2026) is the live SHACL form generator. ShEx: shex.js is active (alpha.33, Sep 2026), PyShEx shipped 0.9.0 (May 2026), shex-java is dormant (2023). RDFUnit (2021) and Validatrr (2017) are dormant. SHACL 1.2 is still a set of W3C Working Drafts (Core, SPARQL, Rules, Node Expressions, UI) as of mid-2026.

### Cited Findings

**pySHACL**
- Apache-2.0, 359 stars, GitHub `updated_at` 2026-10-12 — [GitHub](https://github.com/RDFLib/pySHACL). Releases v0.40.1 (2026-07-28), v0.40.0 (2026-07-08: pass a `pyoxigraph.Store` to `validate()`/`shacl_rules()`, `pyshacl[oxigraph]` extra, SHACL Functions on Oxigraph SPARQL engine; drops `rdflib.ConjunctiveGraph`, breaking), v0.31.0 (2026-01-16: multiple data graphs, `--validate-each`) — [releases page](https://github.com/RDFLib/pySHACL/releases).
- Docker: `docker.io/ashleysommer/pyshacl:latest`; mount data at `/data`; HTTP server with `PYSHACL_SERVER=TRUE`, default `127.0.0.1:8099`, env `PYSHACL_SERVER_PORT`, `PYSHACL_SERVER_LISTEN`, `PYSHACL_SERVER_HOSTNAME`; Swagger at `/docs/swagger`, OpenAPI at `/docs/openapi.json`; `pip install pyshacl[http]`; SHACL-AF rules via `-a`, iterative rules `-it`, SHACL-JS via `-j` (`pyshacl[js]`); implements the 2017 SHACL Recommendation — [GitHub README](https://github.com/RDFLib/pySHACL). Docker Hub `ashleysommer/pyshacl` newest tag v0.30.1 (2025-03-14), `latest` = v0.29.1 (2024-12-16) — image lags PyPI by ~10 releases — [Docker Hub tags](https://hub.docker.com/r/ashleysommer/pyshacl/tags).
- "shaclAPI" (SDM-TIB) is a different tool: uses SHACL validation during SPARQL query execution, runs on port 9999 in Docker, validates over a SPARQL endpoint — [GitHub](https://github.com/SDM-TIB/shaclAPI); [PyPI](https://pypi.org/project/shaclapi). `semmtech/shacl-api` wraps TopBraid SHACL as CLI, Docker Hub updated ~5 years ago — [Docker Hub](https://hub.docker.com/r/semmtech/shacl-api).

**TopQuadrant SHACL API (Java/Jena)**
- Apache-2.0, 246 stars — [GitHub](https://github.com/TopQuadrant/shacl). Releases 1.5.0 (2026-03-23: Jena 6.0.0, Jelly input/output), 1.4.4 (2025-01-13: Jena 5.2.0), 1.4.3 (2024-03-05: lightweight Docker image + GH Action, iterative inference, Jena 4.10) — [releases.atom](https://github.com/TopQuadrant/shacl/releases.atom); [releases page](https://github.com/TopQuadrant/shacl/releases). Prebuilt image `ghcr.io/ashleycaselli/shacl` (`ghcr.io/topquadrant/shacl:VER` is the local-build tag): `docker run --rm -v /path:/data ghcr.io/ashleycaselli/shacl:latest validate -datafile ... [-shapesfile ...]` or `infer`; scripts `shaclvalidate.sh`, `shaclinfer` — [GitHub README](https://github.com/TopQuadrant/shacl).

**Apache Jena SHACL CLI / Fuseki**
- `shacl validate --shapes SHAPES.ttl --data DATA.ttl` (`--shapes` defaults to data file), `shacl parse` outputs text/compact/RDF; validation also exposed as a Fuseki service operation `fuseki:shacl` — [Jena SHACL docs](https://jena.apache.org/documentation/shacl/). (The existing Fuseki container can therefore expose SHACL validation without a new service; the `shacl` CLI needs the Jena binary distribution.)

**RDF4J SHACL** — RDF4J ships a ShaclSail; the stack's RDF4J Workbench already includes it. Jelly-JVM 3.7.3 bumped to rdf4j 5.3.1 — [Jelly-JVM releases](https://github.com/Jelly-RDF/jelly-jvm/releases). (No separate RDF4J SHACL CLI located.)

**SHACL Play (Sparna)**
- LGPL-3.0, Java 11 CLI, 57 stars, GitHub `updated_at` 2026-10-12; functions: validate (HTML report), document (HTML), draw (UML/PlantUML), generate SHACL from RDF, analyze dataset stats, `shacl2sparql`, SHACL rules inference, JSON-LD context and JSON Schema generation, owl2shacl; Docker: `docker build -t shacl-play:latest ./` then `docker run -p 8080:8080 shacl-play:latest`; live demo shacl-play.sparna.fr — [GitHub](https://github.com/sparna-git/shacl-play). Releases 0.12.5 (2026-10-12: `sd:endpoint` links in docs, JSON schema priority fixes, owl2shacl improvements, SVG fix), 0.12.4 (2026-08-25: `--watch` doc option), 0.12.3 (2026-08-10) — [releases.atom](https://github.com/sparna-git/shacl-play/releases.atom); [releases page](https://github.com/sparna-git/shacl-play/releases). No published registry image confirmed (0.12.1 fixed a "Docker packaging" issue).

**ITB SHACL validator (European Commission DIGIT)**
- EUPL-1.2, Java, 30 stars, 0 open issues, GitHub `updated_at` 2026-10-09; web form + REST (Swagger) + SOAP (GITB) + CLI jar; config via "domains" under `validator.resourceRoot`; generic `any` domain when none configured; SBOM published per release — [GitHub](https://github.com/ISAITB/shacl-validator). Docker Hub `isaitb/shacl-validator`: `latest` 2026-10-09, 1.13.0 (2026-09-25), 1.12.4 (2026-08-31), 1.12.3 (2026-08-07); 23 tags — [Docker Hub tags](https://hub.docker.com/r/isaitb/shacl-validator/tags). ITB guide describes running it "on-premise (or local to your workstation)" via Docker — [ITB guide](https://www.itb.ec.europa.eu/docs/guides/latest/validatingRDF/index.html). Port: example URLs use `localhost:8080` (README does not state the port explicitly).

**shacl-form (ULB Darmstadt)**
- "HTML5 web component to edit, view and query RDF data that conform to SHACL"; 92 stars, TypeScript, GitHub `updated_at` 2026-10-09 — [GitHub](https://github.com/ULB-Darmstadt/shacl-form). Releases 3.7.4 (2026-10-09), 3.7.3 (2026-09-22), 3.7.2 (2026-09-07), all bug-fix releases around `sh:qualifiedValueShape`/inheritance — [releases.atom](https://github.com/ULB-Darmstadt/shacl-form/releases.atom). Static web component (serve from any static container).
- W3C "SHACL 1.2 User Interfaces" FPWD published 26 May 2026 by the Data Shapes WG — [W3C review announce, May 2026](https://lists.w3.org/Archives/Public/public-review-announce/2026May/0005.html).

**ShEx**
- shex.js: 62 stars, releases v1.0.0-alpha.33 and .32 (2026-09-14), .31 (2026-09-06) — [releases.atom](https://github.com/shexjs/shex.js/releases.atom); validator package `@shexjs/validator` — [shex.js docs](https://shex.js.org/packages/shex-validator). PyShEx: v0.9.0 (2026-05-07) after a 4-year gap (prior 2022-04-14) — [releases.atom](https://github.com/hsolbrig/PyShEx/releases.atom); ShExJSG was contributed to the LinkML org due to the author's retirement — [PyPI ShExJSG](https://pypi.org/project/ShExJSG/). shex-java (iovka): 10 stars, GitHub `updated_at` 2023-04-12 — [GitHub](https://github.com/iovka/shex-java). No Docker images located for any ShEx tool.

**RDFUnit**
- Apache-2.0, 165 stars; last releases v0.8.23/v0.8.22 (2021-05-16) — [releases.atom](https://github.com/AKSW/RDFUnit/releases.atom); README has a "Using Docker" section; last push reported Sep 2023 by a directory listing — [awesome.ecosyste.ms](https://awesome.ecosyste.ms/projects/github.com%2FAKSW%2FRDFUnit). Dormant.

**Validatrr (IDLab)** — JS, 18 stars, created 2017; GitHub `updated_at` 2026-05-31 but no releases or README content fetched — [GitHub](https://github.com/IDLabResearch/validatrr). Treat as dormant.

**SHACL rules engines** — pySHACL (`-a`, `-it`, `shacl_rules()`), TopQuadrant SHACL (`infer`, iterative inference since 1.4.3), SHACL Play (rules inference) and Jena SHACL all execute SHACL-AF rules; W3C SHACL 1.2 Rules drafts run through 16 Jul 2026 — [W3C shacl12-rules history](https://www.w3.org/standards/history/shacl12-rules/).

**SHACL 1.2 status** — Core WDs through Aug 2026 ([history](https://www.w3.org/standards/history/shacl12-core/); [WD 2026-08-03](https://www.w3.org/TR/2026/WD-shacl12-core-20260803/)); SPARQL Extensions WDs through 28 Aug 2026 ([history](https://www.w3.org/standards/history/shacl12-sparql/)); Node Expressions FPWD 8 Jan 2026, latest 10 Jul 2026 ([history](https://www.w3.org/standards/history/shacl12-node-expr/)). The 2017 SHACL remains the only Recommendation.

**Data-quality dashboards / SPARQL-based quality**
- A July 2025 arXiv paper defines SHACL shapes for 69 data-quality metrics computed from validation results — [arXiv 2507.22305](https://arxiv.org/html/2507.22305v2). `inovexis/csdv` is a containerized SHACL validation worker writing reports to a data sink (not a dashboard) — [Docker Hub](https://hub.docker.com/r/inovexis/csdv). SHACL Play's "analyze" command produces dataset statistics against a SHACL spec — [GitHub](https://github.com/sparna-git/shacl-play). No maintained open-source RDF data-quality dashboard with a Docker image was found.

### Inferences
- pySHACL in server mode is the lowest-effort validation service; because the Docker Hub image lags (v0.30.1), build from `python:3.12-slim` with `pip install pyshacl[http,oxigraph]` to get 0.40.x and Oxigraph support (which matches the stack's Oxigraph).
- SHACL Play adds author-facing features (docs, diagrams, JSON Schema, owl2shacl) that the existing Zazuko SHACL Playground lacks; it must be built from its Dockerfile.
- The ITB validator is the most "productized" validator (versioned images monthly, EUPL, REST+SOAP) and suits teams that want a fixed set of application-profile domains.
- shacl-form can be hosted as a static page beside Blueprint/YASGUI to give SHACL-driven data entry; it is the most active SHACL form generator found.
- ShEx support is thinner: shex.js (Node) is the only actively released validator with a CLI; a `node` one-shot container is enough.

### Gaps
- ITB validator's container port is not stated in the README (examples use 8080).
- No registry-published image for SHACL Play was confirmed.
- Zazuko `shacl-ui` and other SHACL form generators were not inspected.
- RDF4J has no standalone SHACL CLI identified; validation there is via the ShaclSail in the server.
- No open-source "data quality dashboard" for RDF with Docker support was found; only building blocks (pySHACL, SHACL Play analyze, csdv worker).

## Key Question 4: Reasoning / rules as services (EYE/N3, Jena rules, RDFox, Ontop reasoning, cwm, Datalog engines with RDF support, OWL-RL)

### Takeaway
EYE is the clear open-source N3 reasoner to containerize (official `eyereasoner/eye` image, v11.24.8, Sep 2026, MIT) with Eyeling (JS) and pyling (Python) as 2025-2026 lightweight ports; Nemo (Rust Datalog, v0.10.1 Aug 2026, Apache/MIT, GHCR images, RDF and SPARQL-endpoint import) is the most active Datalog engine with RDF I/O; OWL-RL (Python, 7.6.2) covers OWL 2 RL closure in-process; RDFox is proprietary (official image `oxfordsemantic/rdfox:7.7`, Sep 2026, needs a license file). Jena rules and Ontop's OWL 2 QL reasoning come for free with Fuseki and Ontop respectively.

### Cited Findings

**EYE (Euler Yet another proof Engine)**
- MIT, SWI-Prolog, 176 stars, 5,592 commits, GitHub `updated_at` 2026-10-09; implements Notation3 with forward (`=>`) and backward (`<=`) chaining; CLI e.g. `eye --nope --quiet --pass file.n3`; Dockerfile in repo — [GitHub](https://github.com/eyereasoner/eye). Releases v11.24.8 (2026-09-07), v11.24.7 (2026-09-06), v11.24.6 (2026-09-06), skolem-generation fixes — [releases.atom](https://github.com/eyereasoner/eye/releases.atom). Official image `eyereasoner/eye`: tags `latest`/`master`/11.24.8 (2026-09-07); 850 tags; args passed as with native eye, mount working dir — [Docker Hub](https://hub.docker.com/r/eyereasoner/eye/); [tags](https://hub.docker.com/r/eyereasoner/eye/tags). The older `bdevloed/eyeserver` HTTP wrapper is ~5 years stale — [Docker Hub](https://hub.docker.com/r/bdevloed/eyeserver/).
- Eyeling: "a minimal Notation3 (N3) reasoner in JavaScript" announced Dec 2025 under the eyereasoner org — [public-n3-dev Dec 2025](https://lists.w3.org/Archives/Public/public-n3-dev/2025Dec/0001.html); npm `eyeling` v2.35.4, MIT — [depscope](https://depscope.dev/pkg/npm/eyeling). Python port pyling (`pyling-n3` on PyPI) — [GitHub](https://github.com/eyereasoner/pyling). eye-js: WebAssembly build of EYE for Node/browser (`eyereasoner` npm, `n3reasoner`) — [GitHub](https://github.com/smessie/eye-js); [npm](https://www.npmjs.com/package/eyereasoner).

**Nemo (Datalog, Rust)**
- "A fast in-memory rule engine"; Apache-2.0 OR MIT; 308 stars, ~2,580 commits, GitHub `updated_at` 2026-10-13; inputs CSV/TSV/DSV, N-Triples, Turtle, RDF/XML, N-Quads, TriG and SPARQL endpoints; outputs the same RDF formats; CLI `nmo`; browser demo; README warns releases "should still be considered unstable" — [GitHub](https://github.com/knowsys/nemo). Releases v0.10.1 (2026-08-01: `--trace-all-idb-facts`, prefixes auto-available in SPARQL queries), v0.10.0 (2026-03-20: SPARQL import query optional, defaults to virtual import of all triples), v0.9.1 (2025-10-22) — [releases.atom](https://github.com/knowsys/nemo/releases.atom); [releases page](https://github.com/knowsys/nemo/releases). OCI images on GHCR since v0.8.0 at `github.com/knowsys/nemo/pkgs/container/nemo` — [v0.8.0 release](https://github.com/knowsys/nemo/releases/tag/v0.8.0).

**OWL-RL (RDFLib)**
- 180 stars, Python; releases titled "RELEASE 7.6.2" and "7.6.1" (feed timestamps 2026-07-08 and 2026-07-05; release titles say "2025-07-08"/"2025-07-05" — year discrepancy in titles), 7.1.4 (2025-07-29) — [releases.atom](https://github.com/RDFLib/OWL-RL/releases.atom); [GitHub](https://github.com/RDFLib/OWL-RL). Library/CLI, no Docker image.

**RDFox (proprietary)**
- Official images `oxfordsemantic/rdfox` and `oxfordsemantic/rdfox-init`; mount license at `/opt/RDFox/RDFox.lic`; endpoint port 12110; run with `--cap-drop ALL` recommended — [RDFox Docker docs](https://docs.oxfordsemantic.tech/docker.html). Docker Hub tags `latest`/7.7/7.7-docker0 (2026-09-29), 7.7-BETA (2026-08-28), 7.6b (2026-08-03) — [Docker Hub tags](https://hub.docker.com/r/oxfordsemantic/rdfox/tags). Trial license must be requested from the vendor (secondhand: agnos-ai demo) — [agnos-ai/northwind](https://github.com/agnos-ai/northwind). Not open source.

**Ontop reasoning** — Ontop 5.4.0 added `rdfs:subClassOf*` property path support; OWL 2 QL/RDFS ontologies are part of the OBDA setup — [ontop-vkg.org releases](https://ontop-vkg.org/guide/releases.html).

**Jena rules / SHACL inference** — Jena's SHACL CLI and Fuseki `fuseki:shacl` service are documented — [Jena SHACL docs](https://jena.apache.org/documentation/shacl/); Jena's GenericRuleReasoner is part of the Fuseki distribution already in the stack (no new container needed; assembler config required). TopQuadrant SHACL `infer` and pySHACL `shacl_rules()` provide SHACL-AF rule execution (see Q3).

**cwm** — no 2025-2026 activity found in searches (not retrieved); EYE/Eyeling are the maintained N3 engines.

### Inferences
- `eyereasoner/eye` is the only reasoner here with a current official image; wrap it as a one-shot CLI service (mount `/data`) or expose it through a tiny HTTP shim (the old eyeserver image is unmaintained). Eyeling/pyling let you embed N3 reasoning in Node/Python pipeline steps (barnard59, RDF-Connect) without Prolog.
- Nemo can act as a rule-based "materialization" step reading directly from the stack's SPARQL endpoints (QLever/Fuseki/Oxigraph) via its SPARQL import and writing Turtle/N-Quads back, using the GHCR image.
- RDFox should be listed as optional/proprietary with a license-file mount; it is not redistributable in a public compose file.

### Gaps
- Nemo GHCR image tag naming and exact `docker run` syntax were not shown on the fetched pages.
- OWL-RL release-title year discrepancy (titles say 2025, feed says 2026) could not be resolved.
- No information on Souffle-RDF or cwm maintenance was retrieved.
- RDFox trial terms/duration for 2025-2026 were not verified.

## Key Question 5: What is new or notable in 2025-2026 (new RML spec implementations, conference tools, practitioner posts)

### Takeaway
The notable 2025-2026 developments are: the RML CG's move toward a W3C Working Group (Jan 2026) and the KGCW 2026 challenge where CARML and SDM-RDFizer reached 100% conformance on all five tested RML modules; BURP's v0.1.3 (Aug 2026) and BURP-Error fork with RML Execution Reports; Jelly's emergence as a cross-tool RDF streaming format (Morph-KGC, TopQuadrant SHACL, Fuseki/RDF4J plugins, Python, CLI); SPARQL Anything aligning with the new W3C Data Façades CG specs (Oct 2026); SHACL 1.2 progressing through multiple Working Drafts including new Node Expressions and User Interfaces specs; pySHACL gaining an HTTP server and Oxigraph backend; Eyeling/pyling as lightweight N3 reasoners (Dec 2025); and RDF-Connect gaining a Python runner and a SEMANTiCS 2025 tutorial.

### Cited Findings
- RML toward W3C WG: Jan 2026 call to transition the KG Construction CG to a Working Group with a draft charter — [public-kg-construct Jan 2026](https://lists.w3.org/Archives/Public/public-kg-construct/2026Jan/0001.html). RML ontology modular redesign paper (CG, SHACL shapes accompany the spec) — [USC Minerva record](https://minerva.usc.gal/entities/publication/0236d425-a823-47cd-a08a-9182a1eb5ad4).
- KGCW 2026 (7th workshop, 10 May 2026, Dubrovnik) challenge: 5 conformance engines (BURP-Error, Typhon-RML, CARML, MappingWeaver+RMLViewer, SDM-RDFizer), 3 performance engines; "RML-Core 2026 release maintains its focus on JSON files ... other formats reassigned to RML-IO"; exploratory agentic (LLM) mapping track — [CEUR Vol-4245 paper16](https://ceur-ws.org/Vol-4245/paper16.pdf); challenge repo [kg-construct/kgc-challenge](https://github.com/kg-construct/kgc-challenge).
- KGCW 2025 (6th workshop, ESWC 2025, 1 Jun 2025) proceedings — [CEUR Vol-3999](https://ceur-ws.org/Vol-3999/).
- BURP v0.1.3 published 14 Aug 2026 — [Zenodo](https://zenodo.org/doi/10.5281/zenodo.11037711); BURP-Error fork — [jduchateau/BURP-Errors](https://github.com/jduchateau/BURP-Errors).
- rmlmapper-java 8.x line (Sep-Dec 2025; Java 21; Maven Central) — [Zenodo v8.1.0](https://zenodo.org/records/18032528).
- Jelly paper (Jun 2025) and 2026 releases of jelly-jvm 3.7.x, jelly-cli 0.10.0, pyjelly 1.0.x — [arXiv 2506.11298](https://arxiv.org/abs/2506.11298); [jelly-jvm releases](https://github.com/Jelly-RDF/jelly-jvm/releases.atom); [cli releases](https://github.com/Jelly-RDF/cli/releases.atom); [pyjelly releases](https://github.com/Jelly-RDF/pyjelly/releases.atom). Adoption: Morph-KGC 2.10.0 Jelly output ([releases](https://github.com/morph-kgc/morph-kgc/releases)); TopQuadrant SHACL 1.5.0 Jelly I/O ([releases](https://github.com/TopQuadrant/shacl/releases)).
- SPARQL Anything 1.3.0-RC1/RC2 (8 Oct 2026) align with W3C Data Façades CG v0.1 — [releases](https://github.com/SPARQL-Anything/sparql.anything/releases).
- SHACL 1.2 Node Expressions FPWD 8 Jan 2026 — [W3C review announce Jan 2026](https://lists.w3.org/Archives/Public/public-review-announce/2026Jan/0000.html); SHACL 1.2 User Interfaces FPWD 26 May 2026 — [W3C review announce May 2026](https://lists.w3.org/Archives/Public/public-review-announce/2026May/0005.html); SHACL 1.2 Core WD 2026-08-03 — [W3C TR](https://www.w3.org/TR/2026/WD-shacl12-core-20260803/).
- pySHACL 0.40.0 Oxigraph backend (Jul 2026) and 0.31.0 multi-graph validation (Jan 2026) — [releases](https://github.com/RDFLib/pySHACL/releases).
- Eyeling announced Dec 2025 — [public-n3-dev Dec 2025](https://lists.w3.org/Archives/Public/public-n3-dev/2025Dec/0001.html).
- RDF-Connect tutorial at SEMANTiCS 2025 (3 Sep 2025, Vienna); Python runner on PyPI — [PyPI rdfc-runner](https://pypi.org/project/rdfc-runner/); org activity to 14 Oct 2026 — [GitHub org](https://github.com/rdf-connect).
- SEMANTiCS 2025 companion proceedings (11 posters, 9 demos, Developers Workshop) — [CEUR Vol-4064 preface](https://ceur-ws.org/Vol-4064/preface.pdf); KMi report — [blog](https://blog.stem.open.ac.uk/?p=1061). ISWC 2025 ran 2-6 Nov 2025 in Nara — [ISWC 2025 CfP](https://lists.w3.org/Archives/Public/semantic-web/2025Feb/0033.html).
- PyRML paper (May 2025) — [arXiv 2505.20949](https://arxiv.org/pdf/2505.20949). PolicyKG agentic LLM -> SHACL pipeline paper (Aug 2026) — [arXiv 2608.09028](https://arxiv.org/pdf/2608.09028).
- Ontop 5.5.0 (Feb 2026) and 5.4.0 (Sep 2025) — [ontop-vkg.org releases](https://ontop-vkg.org/guide/releases.html).
- LinkML 1.12.0 (Oct 2026: OpenAPI generator, RDFC-1.0 canonical RDF output) — [releases](https://github.com/linkml/linkml/releases).
- Nemo 0.10.x (2026) SPARQL-endpoint virtual import — [releases](https://github.com/knowsys/nemo/releases).

### Inferences
- The 2026 conformance table is the best available neutral evidence for choosing a new-spec RML engine; it favors SDM-RDFizer (published image) and CARML (`rml-cg` branch) over the already-installed RMLMapper for new-spec features (RML-CC, RML-FNML, RML-LV).
- Jelly is becoming the interchange format between the Python mapping world (Morph-KGC, pyjelly) and JVM stores (Fuseki/RDF4J plugins), so adding the plugin JARs to the existing containers is a cheap, forward-looking change.
- SHACL 1.2 is not yet implementable in a stable way (drafts still changing monthly through Aug 2026); pySHACL and TopQuadrant remain on SHACL 2017 + SHACL-AF.

### Gaps
- No practitioner LinkedIn posts or Reddit r/semanticweb threads about concrete RDF ETL Docker stacks in 2025-2026 were returned by the searches performed; only academic venues and tool repos were found.
- ISWC 2025 and SEMANTiCS 2025 demo-track lists were not inspected item by item; no specific new standalone tool launched at those venues was identified.
- MappingWeaver/RMLViewer and Typhon-RML (new KGCW 2026 entrants) were not evaluated for Docker/licensing.
