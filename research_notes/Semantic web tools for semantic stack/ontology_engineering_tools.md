# Open-source ontology engineering tools for a Docker Compose semantic web stack (state as of 2026-10-14)

Scope: candidate editors, visualizers, documentation generators, quality/validation tools and ontology catalogues that could be added to `MetaCoding-io/semantic-stack` (which already ships QLever, Fuseki, Oxigraph, RDF4J Workbench, OntoRefine, OpenRefine, RML Mapper, WebVOWL fork, Trifid, Blueprint, YASGUI, Comunica; SHACL Playground is reserved on host port 8088). Those are not re-recommended below.

Method note for the report writer: GitHub's REST API was blocked in this session, so stars / last-push / release dates were pulled from the ecosyste.ms mirror of GitHub metadata (`https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/{owner}/{repo}` and `/releases`), Docker Hub's public API (`https://hub.docker.com/v2/repositories/{image}/tags`), PyPI JSON and the npm registry, all queried on 2026-10-14. GitHub README pages were read directly. All "stars"/"pushed" figures below are from the ecosyste.ms snapshot unless another source is cited; treat them as approximate (+/- a few stars). Web search budget ran out before LinkedIn/Reddit/SEMANTiCS/OWLGrEd follow-ups could be done; see Gaps.

Host ports already taken in the existing `docker-compose.yml` (from the repo file): 3030, 3333, 7001, 7333, 8082, 8083, 8084, 8085, 8086, 8087, and 8088 reserved (commented-out shacl-playground). Any new service should avoid these.

---

## Key question 1: Ontology / vocabulary / shape editors that run in a browser or in Docker

### Takeaway
There is still no lightweight, officially-dockerised, actively-released open-source OWL editor comparable to Protégé Desktop. WebProtégé is now a Keycloak + MongoDB + RabbitMQ + MinIO microservice stack (official compose repo `webprotege-deploy`, ~14 containers, active 2026 releases); VocBench 3 (v15.1.2, July 2026) is the most mature alternative but has no official Docker image; the most interesting new lightweight entrants are OrionBelt Ontology Builder (Streamlit, single container, BSL-1.1 licence), RDFArchitect (RDFS+SHACL, Apache-2.0, compose) and the SHACL-centric shacl-form / SHACL Play. Chowlk (diagrams.net → OWL) is the one "diagram-to-OWL" tool with a working compose file but it has been quiet since April 2025.

### Cited Findings

**WebProtégé (Stanford) – legacy monolith**
- Repo `protegeproject/webprotege`: 802 stars, last push 2026-07-28, last GitHub release v4.0.2 on 2020-07-31; the README states "This repository is in the process of being superceded", "We are moving WebProtégé to a microservice architecture" and that "all active development is now taking place in these repositories" — [GitHub README](https://github.com/protegeproject/webprotege); [ecosyste.ms metadata](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/protegeproject/webprotege)
- Legacy compose workflow: `docker-compose up -d`, then `docker exec -it webprotege java -jar /webprotege-cli.jar create-admin-account`, app on `http://localhost:5000`, data persisted in `./.protegedata/protege` and `./.protegedata/mongodb` (MongoDB) — [GitHub README](https://github.com/protegeproject/webprotege)
- Docker Hub `protegeproject/webprotege:latest` was last pushed 2019-08-15 (2.47M pulls) — [Docker Hub tags API](https://hub.docker.com/v2/repositories/protegeproject/webprotege/tags)

**WebProtégé – next-generation microservices (active)**
- Org listing shows ~43 `webprotege-*` repos; `webprotege-deploy` ("Compose file for WebProtégé services") pushed 2026-10-08, `webprotege-gwt-ui` 2026-10-08, `webprotege-keycloak`, `webprotege-robot-service` (Spring Boot wrapper around ROBOT, Feb 2026), `webprotege-user-migration-tool` (MongoDB users → Keycloak, Mar 2026) — [protegeproject org repos](https://github.com/orgs/protegeproject/repositories?q=webprotege&type=all&sort=pushed)
- `webprotege-deploy` (BSD-2-Clause, 18–19 stars, created 2021-12-01, pushed 2026-07-28, no tagged releases) compose services and host ports: `webprotege-nginx` :80, `webprotege-keycloak` :8080, `mongo` :27017, `rabbitmq` :5672/:15672, `minio` :9000/:9001, `mailpit` :1025/:8025, `webprotege-gwt-api-gateway` :5008, `webprotege-gwt-ui-server` :8888, `webprotege-backend-service` :5005, `webprotege-authorization-service` :5010, `webprotege-event-history-service` :5006, plus user-management, ontology-processing and initial-revision-history services — [webprotege-deploy README](https://github.com/protegeproject/webprotege-deploy); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/protegeproject/webprotege-deploy)
- Gotchas documented in the README: you must map `webprotege-local.edu` to 127.0.0.1 in `/etc/hosts` ("use this custom domain rather than localhost" because of cookie/Keycloak handling); the first `SystemAdmin` must be granted manually in the Keycloak admin console (realm `webprotege`, open issue #36); change `KEYCLOAK_ADMIN`/`KEYCLOAK_ADMIN_PASSWORD` defaults; SMTP needed for password-reset of migrated users — [webprotege-deploy README](https://github.com/protegeproject/webprotege-deploy)
- Component release cadence: `webprotege-backend-service` 5.0.17 (2026-07-27), `webprotege-gwt-ui` 9.0.25 (2026-07-18), `webprotege-keycloak` 2.0.3 (2026-07-17) — [ecosyste.ms backend](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/protegeproject/webprotege-backend-service/releases), [gwt-ui](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/protegeproject/webprotege-gwt-ui/releases), [keycloak](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/protegeproject/webprotege-keycloak/releases)
- Third-party images exist (e.g. `alexsilaghi93/webprotege-new-keycloak` tags 1.0.0–1.0.4 all pushed 2024-05-15) but have no documentation — [Docker Hub](https://hub.docker.com/r/alexsilaghi93/webprotege-new-keycloak)

**Protégé Desktop (for context)**
- `protegeproject/protege`: 1,556 stars, BSD-2-Clause, releases 5.6.9 (2026-03-07), 5.6.8 (2025-09-03), 5.6.7 (2025-08-09), 5.6.6 (2025-05-23) — [ecosyste.ms releases](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/protegeproject/protege/releases); Wikipedia lists stable 5.6.8 of 3 Sept 2025 — [Wikipedia](https://en.wikipedia.org/wiki/Prot%C3%A9g%C3%A9_(software)); it is a Swing desktop app, not a web app — [protege-distribution](https://github.com/protegeproject/protege-distribution)

**VocBench 3 / Semantic Turkey (Univ. Roma Tor Vergata, EU-funded)**
- EU Interoperable Europe release page: "VocBench 15.1" published 07/05/2026 ("major evolution of the platform… reengineered approach to dataset metadata management"); earlier VocBench3 12.0 (11/12/2023), 11.0 (12/05/2022), 10.0 (30/09/2021), 8.0 (29/09/2020) — [Interoperable Europe releases](https://interoperable-europe.ec.europa.eu/collection/semic-support-centre/solution/vocbench/releases)
- VocBench 15.1.2 + Semantic Turkey 15.1.2 + ShowVoc 6.1.2 announced 2026-07-16; embedded RDF4J client 5.1.6; external RDF4J store must be ≥5.0; GraphDB 11.x officially supported but "GraphDB 11.0 and later limit free use to 5 repositories" — [vocbench-user Google Group](https://groups.google.com/g/vocbench-user/c/pjIfpsgPC3E)
- Project site describes it as "a free and open source RDF modelling platform" but the home/downloads pages do not state the licence; source and binaries are on Bitbucket — [vocbench.uniroma2.it](https://vocbench.uniroma2.it/), [downloads](https://vocbench.uniroma2.it/downloads/)
- No official Docker image. Community images: `ternau/vocbench3` tags 13.0.0 (2025-02-13), 11.4.2 (2024-01-31), 8.0.0 (2020-09-24); `internetofwater/vocbench3-docker:latest` (2025-03-06); `skarampatakis/vocbench-docker` (2018) — [Docker Hub ternau](https://hub.docker.com/v2/repositories/ternau/vocbench3/tags), [internetofwater](https://hub.docker.com/v2/repositories/internetofwater/vocbench3-docker/tags); `ternau/vocbench3` maps port 1979 — [Docker Hub page](https://hub.docker.com/r/ternau/vocbench3)
- Official install is manual: Semantic Turkey server zip + VocBench WAR on Tomcat; the sys-admin manual describes a "standalone distribution" that "contains everything needed to start playing with the system" — [VocBench System Administration Manual](https://vocbench.uniroma2.it/doc/sys)

**OrionBelt Ontology Builder (new, 2025-11)**
- `ralforion/orionbelt-ontology-builder`: 215 stars, created 2025-11-25, pushed 2026-10-04, releases v1.27.8 (2026-09-22), v1.27.7, v1.27.6 — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/ralforion/orionbelt-ontology-builder/releases)
- "Browser-based workbench for OWL ontologies and SKOS vocabularies. Streamlit + rdflib, no Java, no Protégé"; features: OWL class/property/individual/restriction CRUD with undo checkpoints, SKOS schemes with 22 validation checks, RDFS/OWL-RL reasoning via owlrl, SHACL validation via pySHACL, read-only SPARQL console, vis-network graph, Turtle/RDF-XML/N-Triples/N3/JSON-LD import/export, Python API `OntologyManager` — [GitHub README](https://github.com/ralforion/orionbelt-ontology-builder)
- Docker: `docker run --rm -p 8501:8501 ralforion/orionbelt-ontology-builder` (Docker Hub), pin with tag like `:1.29.0`; runs as non-root; Python 3.12+ — [GitHub README](https://github.com/ralforion/orionbelt-ontology-builder)
- Licence gotcha: Business Source License 1.1 that "will convert to Apache License 2.0 on 2030-03-30"; CLA required — [GitHub README](https://github.com/ralforion/orionbelt-ontology-builder)

**RDFArchitect (SOPTIM, new 2026-02)**
- `SOPTIM/RDFArchitect`: 28 stars, Apache-2.0, created 2026-02-17, pushed 2026-10-11, releases v1.6.0 (2026-09-10), v1.5.0, v1.4.0 — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/SOPTIM/RDFArchitect/releases)
- "web-based tool for visualizing, editing, and sharing RDFS schemas with CIM extensions… plus their SHACL constraints"; UML-style class diagrams, schema compare/migration, SHACL rule generation; `docker compose up --build` from `docker/` then `http://localhost:3000` (nginx gateway; backend 8080, DB HTTP endpoint 3030 inside compose); Java 25 + Spring Boot, SvelteKit — [GitHub README](https://github.com/SOPTIM/RDFArchitect)

**ProtegeDesk (new, early stage)**
- `aadorian/ProtegeDesk`: 10–14 stars, MIT, created 2025-12-30, pushed 2026-06-28, no releases; Next.js 16/React 19 web editor with Manchester-syntax axiom editor, LLM axiom generation, client-side "HermiT-inspired" reasoner; v0.2.0 labelled "MVP Development"; no Docker, `npm run dev` on port 3000 — [GitHub README](https://github.com/aadorian/ProtegeDesk); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/aadorian/ProtegeDesk)

**Chowlk (diagrams.net → OWL)**
- `oeg-upm/chowlk`: 47 stars, Apache-2.0, last push 2025-04-11, only release v0.0.1 (2020-12-09); default branch `webservice` (254 commits), 16 open issues — [GitHub](https://github.com/oeg-upm/chowlk); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/oeg-upm/chowlk)
- Docker: clone, checkout `webservice`, `docker compose up`, open `localhost:5000`; input is a diagrams.net XML drawn with the Chowlk notation; output Turtle (default) or RDF/XML; hosted at chowlk.linkeddata.es with a `curl -F 'data=@diagram.xml'` API — [GitHub README](https://github.com/oeg-upm/chowlk); paper "Chowlk: from UML-Based Ontology Conceptualizations to OWL" (ESWC 2022) — [ESWC 2022 paper](https://2022.eswc-conferences.org/wp-content/uploads/2022/05/paper_90_Chavez-Feria_et_al.pdf)

**OWLGrEd / CoModIDE / OntoUML / Menthor**
- OWLGrEd site offers a "Get Desktop Editor" download, copyright 2013–2026, no licence or version stated, no online version mentioned — [owlgred.lumii.lv](http://owlgred.lumii.lv/)
- CoModIDE is a Protégé plugin (Kansas State); most recent material found is the 2020 ESWC paper/evaluation; no 2025 status found — [CoModIDE ESWC 2020](https://www.cs.ksu.edu/~hitzler/pub2/2020_ESWC_CoModIDE.pdf)
- OntoUML: `OntoUML/ontouml-vp-plugin` 33 stars, Apache-2.0, last release 0.5.3 (2021-12-14), pushed 2024-05-30; `OntoUML/ontouml-server` 6 stars, pushed 2022-12-11, no releases; `OntoUML/ontouml-js` pushed 2026-07-26 — [ecosyste.ms vp-plugin](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/OntoUML/ontouml-vp-plugin), [server](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/OntoUML/ontouml-server), [js](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/OntoUML/ontouml-js); the plugin "is currently a proof of concept" and "some features are based on web services that process your model remotely" and requires Visual Paradigm (proprietary) — [purl.org/ontouml-vp](https://purl.org/ontouml-vp)
- `MenthorTools/menthor-editor` (OntoUML desktop editor) is archived, last push 2021-03-10 — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/MenthorTools/menthor-editor)

**SHACL shape / form editors**
- `ulb-darmstadt/shacl-form`: 92 stars, MIT, "HTML5 web component to edit, view and query RDF data that conform to SHACL"; GitHub release v3.4.2 (2026-08-11), pushed 2026-10-09; npm `@ulb-darmstadt/shacl-form` 3.7.4 published 2026-10-09; use via npm or `https://cdn.jsdelivr.net/npm/@ulb-darmstadt/shacl-form/dist/bundle.js`; demo at ulb-darmstadt.github.io/shacl-form; no Docker image — [GitHub](https://github.com/ulb-darmstadt/shacl-form); [npm](https://registry.npmjs.org/@ulb-darmstadt/shacl-form); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/ulb-darmstadt/shacl-form)
- `sparna-git/shacl-play` (SHACL Play!): 57 stars, LGPL-3.0, release 0.12.1 (2026-06-15), pushed 2026-10-12; features: validate RDF against SHACL with readable report, generate HTML documentation of a SHACL profile, draw UML diagrams from SHACL, generate SHACL from a dataset, dataset statistics, SHACL→SPARQL, apply SHACL rules; Docker: `docker build -t shacl-play:latest ./` then `docker run -p 8080:8080 shacl-play:latest`; Java 11 CLI — [GitHub](https://github.com/sparna-git/shacl-play); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/sparna-git/shacl-play); no official Docker Hub image found by search — [Docker Hub search API](https://hub.docker.com/v2/search/repositories/?query=shacl-play)
- `zazuko/shacl-playground` (already reserved in the stack): 34 stars, release `shacl-playground@1.3.10` (2026-05-28), pushed 2026-10-03; fully client-side on rdf-validate-shacl; `docker build -t shacl-playground .` then `docker run -p 80:80`; Zazuko states it is AGPL — [GitHub](https://github.com/zazuko/shacl-playground); [zazuko.com tools page](https://zazuko.com/tools/shacl-playground/)
- `TopQuadrant/shacl` (Java SHACL API on Jena, includes `shaclvalidate`/`shaclinfer` CLIs): 246 stars, Apache-2.0, v1.5.0 (2026-03-23) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/TopQuadrant/shacl); the only Docker image found (`semmtech/shacl-api` 1.3) dates from 2021-02-23 — [Docker Hub](https://hub.docker.com/v2/repositories/semmtech/shacl-api/tags)
- `danielbeeke/shacl-form` (different project) is stale: 7 stars, last push 2023-10-05 — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/danielbeeke/shacl-form)
- Standards/upcoming: a Sept 2025 commit "added a new editor to the SHACL UI spec" (W3C SHACL CG list) — [public-shacl Sept 2025](https://lists.w3.org/Archives/Public/public-shacl/2025Sep/0029.html); NLnet-funded "ShapeThing" (UI generation from SHACL, start 2026-03, to integrate with "upcoming SHACL UI 1.2") — [NLnet project page](https://nlnet.nl/project/ShapeThing/); W3C `w3c/shacl` CG repo archived (last push 2025-01-27) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/w3c/shacl)

**LinkML (schema language with OWL/SHACL generators)**
- `linkml/linkml`: 649 stars, Apache-2.0, pushed 2026-10-09; GitHub release listing shows v1.10.0-rc1 (2025-11-21) while PyPI `linkml` is at 1.12.1 (uploaded 2026-10-13) — releases on GitHub lag PyPI — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/linkml/linkml), [PyPI JSON](https://pypi.org/pypi/linkml/json); repo root has a `Dockerfile`; topics include owl and shacl — [GitHub](https://github.com/linkml/linkml)
- `linkml/schema-automator` v0.5.5 (2026-04-06), 67 stars, BSD-3 — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/linkml/schema-automator/releases); `linkml-project-cookiecutter` is archived (pushed 2025-10-23) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/linkml/linkml-project-cookiecutter)

**SKOS editors (adjacent to ontology editing)**
- `innoq/iqvoc`: 124 stars, pushed 2026-10-07 but last tagged release v4.11.1 is from 2017-06-19; Rails app; Docker Hub `innoq/iqvoc_postgresql` exists (4.2k pulls) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/innoq/iqvoc); [Docker Hub search](https://hub.docker.com/v2/search/repositories/?query=iqvoc); iQvoc is Apache-2.0 per datos.gob.es review — [datos.gob.es](https://datos.gob.es/en/noticias/tools-management-controlled-vocabularies-skos-suppor)
- `tematres/TemaTres-Vocabulary-Server`: 142 stars, v3.6.1 (2026-04-30), pushed 2026-10-01; GPL; "Internally, it uses a model based on terms, which differs from a model based on concepts" (SKOS) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/tematres/TemaTres-Vocabulary-Server/releases); [datos.gob.es](https://datos.gob.es/en/noticias/tools-management-controlled-vocabularies-skos-suppor)
- `skohub-io/skohub-vocabs` ("lightweight tool to publish SKOS vocabularies"): 45 stars, Apache-2.0, pushed 2026-07-02, no releases — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/skohub-io/skohub-vocabs); a SWIB forum commenter noted SkoHub "still requires editing Turtle files directly" — [SWIB forum](https://forum.swib.org/t/a-domain-agnostic-toolkit-for-community-curated-skos-vocabularies/1607)

### Inferences
- For a *developer-machine* compose stack, WebProtégé next-gen is heavy (Keycloak, MongoDB, RabbitMQ, MinIO, mailpit, nginx + ~8 Java services, custom hostname). It is feasible as an *optional profile* using `webprotege-deploy` as reference, but port 8080 (Keycloak) and 80 (nginx) would need remapping, and the legacy single-container image (2019) should not be used.
- VocBench 3 is the most capable editor (OWL + SKOS + OntoLex + SHACL + collaboration) and is actively released (15.1.2, July 2026), but adding it means either a community image lagging 2 major versions (13.0.0) or writing a Dockerfile around the standalone zip; it also pushes users toward GraphDB/RDF4J rather than the stack's QLever/Fuseki.
- OrionBelt is the easiest "ontology editor in one container" to add (single image, port 8501), but its BSL-1.1 licence is not OSI open source until 2030 — flag in README.
- shacl-form and SHACL Play together cover "SHACL shape editing/doc/UML" better than any single dedicated shape editor found; SHACL Play has a trivially buildable Docker image and complements the already-reserved SHACL Playground (which only validates).
- Chowlk is the only diagram-to-OWL tool with a ready compose file; its inactivity since 2025-04 and v0.0.1 tag are maintenance risks.

### Gaps
- VocBench 3 licence not confirmed from primary pages fetched (project site and downloads page do not state it; EU page not checked for licence) — treat as "free and open source" per project site, exact licence unverified.
- Could not fetch the Bitbucket downloads listing (returned empty), so the exact 15.1.x artefact names/dates come only from the mailing list and EU page.
- OWLGrEd licence/version and CoModIDE 2025 status: no primary data found (search budget exhausted).
- No LinkedIn or Reddit practitioner posts recommending editors were retrievable (searches returned none before the budget ran out).
- Semantic Turkey standalone Docker: no official image; only `informea/semantic-turkey` (272 pulls, undated) seen in Docker Hub search — [Docker Hub search](https://hub.docker.com/v2/search/repositories/?query=semantic-turkey)

---

## Key question 2: Ontology visualization successors / alternatives to WebVOWL

### Takeaway
WebVOWL itself is unmaintained as a product (last release 1.1.6, Oct 2019; README warns the root Dockerfile is broken), so the live options are: (a) Ontodia-lineage graph libraries that are actively released in 2026 — Reactodia Workspace (v0.35.x) and Zazuko's `graph-explorer` fork (v2.0.1, July 2026); (b) AWS `graph-explorer` (v3.1.0, June 2026, official container image, works with any SPARQL 1.1 endpoint); (c) Sparnatural (SHACL-configured visual query builder, 13.x); (d) documentation-embedded viewers — OntoInk (MkDocs plugin, ISWC 2026 companion, HermiT/Konclude/owlrl reasoning + SHACL overlay) and Grapholscape; (e) OntView (2025, desktop JavaFX, reasoner-driven). No drop-in VOWL-notation successor with a maintained Docker image was found.

### Cited Findings

**WebVOWL / OWL2VOWL status**
- `VisualDataWeb/WebVOWL`: 1,009 stars, MIT, last release 1.1.6 (2019-10-08), last push 2026-06-04 (README maintenance); README says the old visualdataweb.org domain "is no longer owned by the project" and points to service.tib.eu/webvowl/, and that "the legacy root Dockerfile is broken (issue #212)" — [GitHub](https://github.com/VisualDataWeb/WebVOWL); [ecosyste.ms releases](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/VisualDataWeb/WebVOWL/releases)
- `VisualDataWeb/OWL2VOWL` (converter): 154 stars, MIT, no releases, last push 2026-06-04 — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/VisualDataWeb/OWL2VOWL)
- Scalability: an OntoPlot study reported "scalability issues with WebVOWL appeared when visualizing medium to large ontologies" — [OntoPlot arXiv 1908.00688](https://arxiv.org/pdf/1908.00688)

**Ontodia lineage**
- Original `ontodia` npm package is stuck at 0.12.2 (2020-03-25, LGPL-2.1) — [npm registry](https://registry.npmjs.org/ontodia)
- `reactodia/reactodia-workspace`: 33 stars, LGPL-2.1-or-later, "an open-source fork of Ontodia project", TypeScript library; releases v0.35.1 (2026-07-10), v0.35.0, v0.34.1, v0.34.0, v0.33.0, v0.32.0 (all 2026); npm `@reactodia/workspace` 0.35.2 (2026-08-08); RDF loaded via `RdfDataProvider` (N3/Turtle); no standalone app or Docker image in README — [GitHub](https://github.com/reactodia/reactodia-workspace); [ecosyste.ms releases](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/reactodia/reactodia-workspace/releases); [npm](https://registry.npmjs.org/@reactodia/workspace)
- `zazuko/graph-explorer`: "a fork of Ontodia, which is now part of Metaphacts"; 79–80 stars, releases v2.0.1 and v2.0.0 (2026-07-21), pushed 2026-08-25; npm `graph-explorer`; demo on `http://localhost:10444/` with `SPARQL_ENDPOINT=<url> npm run demo` → `envendpoint.html`; licence not named in README (ecosyste.ms: "other"); no Docker image in README — [GitHub](https://github.com/zazuko/graph-explorer); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/zazuko/graph-explorer/releases)
- Metaphactory (commercial) still offers "a commercial license… for extra features and support" of Ontodia — [npm ontodia README](https://www.npmjs.com/package/ontodia)

**AWS graph-explorer**
- `aws/graph-explorer`: 484 stars, Apache-2.0, v3.1.0 (2026-06-10), pushed 2026-10-09; "React-based web application that enables users to visualize both property graph and RDF data"; connects to any database supporting "W3C RDF/SPARQL" over HTTP — [GitHub](https://github.com/aws/graph-explorer); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/aws/graph-explorer/releases)
- Official image `public.ecr.aws/neptune/graph-explorer:latest`, ports 80 and 443, `HOST` env var; launch note: "can connect to Amazon Neptune or another graph database that provides an Apache TinkerPop Gremlin or SPARQL 1.1 endpoint"; "the proxy server will only be necessary if you are connecting to Neptune"; default HTTPS uses a self-signed cert — [AWS Neptune docs](https://docs.aws.amazon.com/neptune/latest/userguide/visualization-graph-explorer.html); [AWS announcement 2023](https://aws.amazon.com/about-aws/whats-new/2023/01/neptune-graph-explorer-open-source-visual-exploration-tool-low-code-users)

**Sparnatural**
- `sparna-git/Sparnatural`: 312 stars, LGPL-3.0, "visual client-side SPARQL query builder for exploring and navigating RDF Knowledge Graphs", configured "through a SHACL configuration file" (Excel template available); GitHub release 13.0.0-beta3 (2026-07-06), npm `sparnatural` 13.1.0 (2026-09-29); web component, no Docker image — [GitHub](https://github.com/sparna-git/Sparnatural); [npm](https://registry.npmjs.org/sparnatural); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/sparna-git/Sparnatural/releases)

**OntoInk (new, Oct 2026)**
- arXiv 2610.05945 (submitted 5 Oct 2026, "ISWC 2026 Companion Volume"), FIZ Karlsruhe (Norouzi, Waitelonis, Sack): "open-source MkDocs plugin that combines ontology visualization, SHACL validation, OWL reasoning, and inline Turtle editing"; built on rdflib + pySHACL (build time) + client-side SHACL engine; reasoners HermiT (via owlready2, default), Konclude, Konclude-compiled-to-WebAssembly, OWL-RL fallback; demo ise-fizkarlsruhe.github.io/ontoink — [arXiv HTML](https://arxiv.org/html/2610.05945)
- `ISE-FIZKarlsruhe/ontoink`: MIT, 3–6 stars, release v0.7.3 (2026-07-20); PyPI `ontoink` 0.7.9 (2026-10-08); `pip install ontoink`, add to `mkdocs.yml` plugins; requires Python ≥3.9, MkDocs ≥1.4, rdflib ≥6, pySHACL ≥0.25; repo contains a Dockerfile and docker-compose.yml and docs mention "production image, reasoner backends, API mode" — [GitHub](https://github.com/ISE-FIZKarlsruhe/ontoink); [PyPI JSON](https://pypi.org/pypi/ontoink/json); [docs](https://ise-fizkarlsruhe.github.io/ontoink/)

**OntView (2025)**
- arXiv 2507.13759 (18 Jul 2025): ontology viewer using a DL reasoner so the view shows inferred knowledge ("What you see is what you meant"), supports GCIs — [arXiv](https://arxiv.org/abs/2507.13759)
- `cbobed/OntView`: 8 stars, desktop Java/JavaFX run via Maven, bundles Openllet and HermiT; sidebar says Apache-2.0 while README says dual LGPL-3/Apache-2 (conflict); no releases, pushed 2026-04-30; no Docker — [GitHub](https://github.com/cbobed/OntView); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/cbobed/OntView)

**Grapholscape**
- `obdasystems/grapholscape`: 22 stars, MIT, "Web viewer for ontologies written in Graphol" built on cytoscape.js; last release v4.0.11 (2024-10-02), pushed 2026-07-03; static web app + npm package; no Docker — [GitHub](https://github.com/obdasystems/grapholscape); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/obdasystems/grapholscape)

**Other viewers seen (lower priority)**
- `usc-isi-i2/ontology-visualization` (Python → Graphviz): 140 stars, MIT, last push 2022-09-20 — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/usc-isi-i2/ontology-visualization)
- `zazuko/rdf-sketch` ("Sketch RDF in the web browser with immediate visualization", web app + VS Code extension): 46 stars, MIT, no releases, pushed 2026-03-31; npm `@zazuko/rdf-sketch` 0.1.3 (2022-08-09); no Docker — [GitHub](https://github.com/zazuko/rdf-sketch); [npm](https://registry.npmjs.org/@zazuko/rdf-sketch)
- `yWorks/ontology-visualizer` is a yFiles (proprietary library) sample — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/yWorks/ontology-visualizer)
- `OnToology/OnToology` also produces diagrams via AR2DTool (see Q3) — [GitHub](https://github.com/OnToology/OnToology)
- GitHub topic `ontology-visualization` (sorted by update) lists only 10 repos; newest are a TIB mirror and `TALOS-AI4SSH/OTV-Ontology-Viewer` (0 stars) — [GitHub topic](https://github.com/topics/ontology-visualization?o=desc&s=updated)
- Notation-based tools cited by the OntoInk paper as the comparison set: Graffoo/OWL2Graffoo, Chowlk, OWLGrEd — [arXiv 2610.05945](https://arxiv.org/html/2610.05945)

### Inferences
- The lowest-friction WebVOWL *companion* (not replacement) with an official image is AWS graph-explorer: one container, generic SPARQL 1.1, can point at the stack's QLever/Fuseki/Oxigraph; it visualises instance data rather than VOWL-style class diagrams, so it complements rather than replaces WebVOWL.
- For a VOWL-like *schema* view the practical path is either keeping the WebVOWL fork (with a fixed Dockerfile) or building a tiny static container around Reactodia/Zazuko graph-explorer pointed at a SPARQL endpoint; both are libraries, so a small wrapper page is required.
- OntoInk is the most "2026" option: it turns the stack's ontologies into a browsable, reasoned, SHACL-annotated docs site in one MkDocs container; its star count is tiny but it has a Dockerfile, monthly releases and an ISWC 2026 companion paper.

### Gaps
- Could not open the Reactodia playground page (404 on the guessed URL) to confirm whether a standalone, self-hostable app exists.
- Zazuko graph-explorer licence not shown in README (ecosyste.ms "other"); verify LICENSE file before adoption.
- No Docker image for Grapholscape, Reactodia, Sparnatural, rdf-sketch — all would need a trivial nginx wrapper.

---

## Key question 3: Documentation generators and ontology browsers / catalogues

### Takeaway
WIDOCO (Java, `ghcr.io/dgarijo/widoco`, v1.4.25) and pyLODE (Python, 3.6.0 Aug 2026, built-in HTTP server on port 8000 with Dockerfile targets) remain the two standard OWL doc generators and both are dockerisable today; SHACL Play adds SHACL-profile documentation. For a browsable catalogue, EBI OLS4 is now a 3-service compose stack (PostgreSQL+pgvector, Spring backend, React frontend on :8081, with an MCP endpoint) and is actively released (v4.0.1–4.0.3, Oct 2026), whereas OntoPortal's Docker repos are stale forks (2023). Skosmos 3 (v3.4, Aug 2026, quay.io image) is the SKOS browser of choice and already uses Fuseki.

### Cited Findings

**WIDOCO**
- `dgarijo/Widoco`: 402 stars, Apache-2.0, last release v1.4.25 (2024-06-30; "fixes documentation broken links, clarifies how to download Docker images and includes a new option for excluding the provenance page"), pushed 2026-10-01; README mentions a Dockerfile and pre-built images at `ghcr.io/dgarijo/widoco`; requires Java 1.8+; based on LODE; can "produce an automatic changelog of differences between the actual and the previous version of the ontology" — [GitHub](https://github.com/dgarijo/Widoco); [ecosyste.ms releases](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/dgarijo/Widoco/releases)
- Several community Docker Hub images exist (`mikidi/widoco`, `okp4/widoco`, `neeohw/widoco`…) — [Docker Hub search](https://hub.docker.com/v2/search/repositories/?query=widoco)

**pyLODE**
- `RDFLib/pyLODE`: 230 stars, BSD-3-Clause; GitHub release 3.5.2 (2026-08-06), PyPI `pylode` 3.6.0 (2026-08-17), pushed 2026-09-19; modes `ontpub` (default), `vocpub` (SKOS), `supermodel` (profiles of profiles) and `valpub` (SHACL shapes graphs); Falcon HTTP server (`python -m pylode.server`, endpoint `/pylode?url=…&profile=…`), Dockerfile with targets `pylode-server` and `pylode-gunicorn` on port 8000 — [GitHub](https://github.com/RDFLib/pyLODE); [PyPI JSON](https://pypi.org/pypi/pylode/json); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/RDFLib/pyLODE/releases)
- 3.0.1 was a rewrite that "only handles OWL 'ontologies' and doesn't yet cover all the profile types that pyLODE 2.13.2 did" — [PyPI page](https://pypi.org/project/pylode); community image `secoresearch/pylode` has 115k pulls (tag dates not retrieved) — [Docker Hub search](https://hub.docker.com/v2/search/repositories/?query=pylode)

**Ontospy**
- `lambdamusic/Ontospy`: 251 stars, MIT, GitHub release v2.1.1 (2022-11-16), pushed 2024-03-07, maintainer notes limited time; but PyPI `ontospy` 2.5 was uploaded 2026-10-13 — [GitHub](https://github.com/lambdamusic/Ontospy); [PyPI JSON](https://pypi.org/pypi/ontospy/json); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/lambdamusic/Ontospy)

**OnToology (GitHub-integrated doc+eval service)**
- `OnToology/OnToology`: 116 stars, Apache-2.0, pushed 2026-06-11, last release v1.7.1 (2021-06-22); wraps Widoco, OOPS! (oops.linkeddata.es), AR2DTool (diagrams), owl2jsonld, Themis; self-hosting requires configuring `localwsgi.py`, running a "stiqueue" server and `sqclient.py`; no Docker; 81 open issues — [GitHub](https://github.com/OnToology/OnToology); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/OnToology/OnToology/releases)

**SHACL documentation**
- SHACL Play "Generate HTML documentation for a SHACL application profile" and "Draw UML-style diagrams from SHACL" (see Q1) — [GitHub](https://github.com/sparna-git/shacl-play)

**LinkML docs**
- LinkML README/topics only; the `gen-doc`/markdown generator docs page returned 404 in this session — [GitHub](https://github.com/linkml/linkml) (see Gaps)

**EBI OLS4 (ontology lookup/catalogue)**
- `EBISPOT/ols4`: 105 stars, Apache-2.0, pushed 2026-10-08; GitHub releases page lists v4.0.3 (08 Oct), v4.0.2 (07 Oct), v4.0.1 (06 Oct) (year not printed on the page; these are the newest entries); v4.0.3's only change is "adding OLS citation and FTP data release information to the About page (PR #1462)" — [GitHub releases](https://github.com/EBISPOT/ols4/releases); [v4.0.3 tag](https://github.com/EBISPOT/ols4/releases/tag/v4.0.3); ecosyste.ms only indexes a tag `ols4-paper` (2025-03-03) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/EBISPOT/ols4/releases)
- Current README (dev branch, shown as repo front page): compose services `ols4-postgres` (PostgreSQL with pgvector), `ols4-backend` (Spring Boot), `ols4-frontend` (React); dataload first: `OLS4_CONFIG=./dataload/configs/efo.json ./dataload.sh` (needs Docker, writes DB to `out/`), then `HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up`; frontend `http://localhost:8081`, Postgres 5432; to load your own ontology copy `efo.json`, set `ontology_purl` to e.g. `./myontology.owl`; features an MCP server ("stateless Streamable HTTP"); "No OWL reasoning; ontologies are expected to be pre-reasoned"; memory requirements not stated — [GitHub README](https://github.com/EBISPOT/ols4); [dev README](https://github.com/EBISPOT/ols4/blob/dev/README.md)
- Earlier OLS4 architecture (Solr + Neo4j) is described in the OLS4 paper (arXiv 2501.13034) and the ELIXIR FAIR Cookbook recipe (which targets OLS3 docker via `ontotools-docker-config`) — [arXiv](https://arxiv.org/abs/2501.13034v1); [FAIR Cookbook](https://faircookbook.elixir-europe.org/content/recipes/infrastructure/vocabularies/UC3_R13_local_ontology_services.html); [TIB TS fork](https://github.com/TIBHannover/TS)
- No `ebispot/ols4*` images were found on Docker Hub via the API (images are built by compose) — [Docker Hub tags API (404)](https://hub.docker.com/v2/repositories/ebispot/ols4-backend/tags)

**OntoPortal / BioPortal appliance**
- OntoPortal Virtual Appliance is "a rebranded version of the BioPortal Virtual Appliance… based on BioPortal's v5.x software infrastructure, including the use of an RDF triplestore"; distributed as VMware OVF and AWS AMI — [bioontology.org wiki](https://www.bioontology.org/wiki/OntoPortalVA); [2019 poster](https://hal-lirmm.ccsd.cnrs.fr/lirmm-02360625)
- `ncbo/ontoportal_docker` (0 stars, pushed 2023-11-07), `ontoportal/ontoportal_docker` (fork, pushed 2023-11-12), `ontoportal-lirmm/ontoportal_docker` (fork, pushed 2025-06-02); README: 4store default triplestore (AllegroGraph optional), API on `localhost:9393` via `dip`, ncbo_cron — [GitHub ontoportal_docker](https://github.com/ontoportal/ontoportal_docker); [ecosyste.ms ncbo](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/ncbo/ontoportal_docker), [lirmm](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/ontoportal-lirmm/ontoportal_docker)

**Skosmos (SKOS browser)**
- `NatLibFi/Skosmos`: 267 stars, MIT, releases v3.4 (2026-08-31), v3.3 (2026-06-09), v3.2 (2026-03-31), v3.1 (2026-02-06), v3.0 (2025-12-10); pushed 2026-10-05 — [ecosyste.ms releases](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/NatLibFi/Skosmos/releases); [GitHub](https://github.com/NatLibFi/Skosmos)
- Official image `quay.io/natlibfi/skosmos:latest` updated 2026-10-05 — [quay.io API](https://quay.io/api/v1/repository/natlibfi/skosmos/tag/?limit=5)
- `dockerfiles/README.md`: compose services `fuseki` (Jena Fuseki, 2 GB), `fuseki-cache` (Varnish, caches gzipped results one week), `skosmos-web`; Skosmos on `http://localhost:9090/`, Fuseki host port documented inconsistently (3030/9030/9031), overridable with `SKOSMOS_PORT`, `FUSEKI_PORT`, `CACHE_PORT`; Fuseki dataset must be named `skosmos` with JenaText; vocabularies loaded by `POST /skosmos/data?graph=<uri>` with `text/turtle`; config mounted at `/var/www/html/config.ttl` — [dockerfiles README](https://github.com/NatLibFi/Skosmos/blob/main/dockerfiles/README.md); install tutorial: `v3.4-maintenance` branch, Fuseki 5.6.0 needs Java 17+ — [Skosmos wiki InstallTutorial](https://github.com/NatLibFi/Skosmos/wiki/InstallTutorial); PHP backend, usually Fuseki — [NKOS 2025 slides](https://nkos.dublincore.org/2025NKOSworkshop/NKOS%20Skosmos%20and%20Annif.pdf)

**Prez (Linked Data API over SPARQL)**
- `RDFLib/prez`: 39 stars, BSD-3-Clause, v4.23.7 (2026-07-20), pushed 2026-10-06, "data-configurable Linked Data API framework that delivers profiles of Knowledge Graph data" — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/RDFLib/prez/releases) (README fetch of the `kurrawong/prez` fork returned 404)

**Ontology Access Kit (OAK)**
- `INCATools/ontology-access-kit`: 201 stars, Apache-2.0, v0.7.4 (2026-08-03) — Python library/CLI, not a server — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/INCATools/ontology-access-kit/releases)

### Inferences
- WIDOCO + pyLODE could be added as *on-demand* services: pyLODE's server mode (`/pylode?url=`) on port 8000 is a natural sidecar for Trifid/Fuseki-hosted ontologies; WIDOCO is a CLI (run via `docker run` / compose `profiles`), not a long-running service.
- OLS4 is adoptable as an optional profile (3 containers + a one-off dataload); it needs the host UID/GID trick and the dataload step before `up`, and it does no reasoning (pre-reason with ROBOT).
- OntoPortal is not a realistic developer-machine addition (4store/AllegroGraph, Ruby stack, stale compose forks).
- Skosmos's compose expects its own Fuseki + Varnish; it can be pointed at the stack's existing Fuseki (dataset with JenaText) to avoid a second triple store, but port 9090/3030 defaults must be reconciled (3030 is already used by the stack's Fuseki).

### Gaps
- LODE (original) and OntoDoc were not checked.
- OLS4 memory/CPU requirements are not stated in the README; the Solr/Neo4j → Postgres/pgvector transition timing is not documented on the pages read (the release page for v4.0.3 has no migration notes). Verify which OLS4 version first required Postgres before pinning.
- Year of OLS4 v4.0.1–4.0.3 releases not printed on GitHub's release page (they appear at the top, so very likely Oct 2026, but unverified).
- LinkML `gen-doc` details could not be fetched (404).

---

## Key question 4: Quality, validation and reasoning services

### Takeaway
pySHACL (v0.40.1, July 2026) is the only SHACL validator with an official HTTP mode and Docker image (though the Docker Hub tag lags the PyPI release); rudof (Rust, v0.3.10 Aug 2026, Docker `angelip2303/rudof`) is the most active ShEx+SHACL+DCTAP engine, with shex.js (alpha.33, Sept 2026) as the JS ShEx reference. FOOPS! (v0.4.0, May 2026) is an actively maintained Spring Boot FAIR-assessment service; OOPS! has a 0.2.0 source release (June 2025) but only a community Docker image. For reasoning-as-a-service, Konclude (Docker 2021, OWLlink/SPARQL HTTP on 8080) and Owlery (Docker 2022) are the only HTTP reasoners found, both stale; ROBOT (v1.9.10, Feb 2026, `obolibrary/robot`) and ODK (`obolibrary/odkfull` v1.6.1, Mar 2026) are the healthy CLI toolboxes that bundle ELK/HermiT/JFact/Whelk.

### Cited Findings

**OOPS! (OntOlogy Pitfall Scanner)**
- `oeg-upm/OOPS`: 10 stars, Apache-2.0 (README; ecosyste.ms shows no licence), release 0.2.0 (2025-06-24), pushed 2025-07-01; build with Maven, deploy WAR to Tomcat 10 (example `localhost:8080/oops-2.0.0-SNAPSHOT`); no Docker instructions — [GitHub](https://github.com/oeg-upm/OOPS); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/oeg-upm/OOPS/releases)
- Community image `mpovedavillalon/oops` tags v2 (2024-12-10), v1 (2024-10-07), ~1.5k pulls — [Docker Hub tags](https://hub.docker.com/v2/repositories/mpovedavillalon/oops/tags); OOPS! classifies pitfalls as critical/important/minor and offers a REST service; hosted at oops.linkeddata.es — [SWJ paper page](https://www.semantic-web-journal.net/node/989); [UPM listing](https://www.upm.es/recursosidi/en/offers-resources/software-en/oops-oops-ontology-pitfall-scanner-2/)

**FOOPS! (FAIR assessment of ontologies)**
- `oeg-upm/fair_ontologies`: 26 stars, Apache-2.0, release v0.4.0 (2026-05-04), pushed 2026-09-28; build with Maven/JDK 11, run `java -jar -Dserver.port=PORT fair_ontologies-x.y.z.jar` (README example port 8083 — collides with the stack's WebVOWL on 8083, so remap); REST: `POST /assessOntology`, `POST /assessOntologyFile`, `GET /tests`, `GET /metrics`, `GET /benchmarks/{id}`; Swagger at `/swagger-ui/index.html`; URI-based assessment fetches the ontology online and test FIND3 checks w3id/purl registries (needs internet); no Docker instructions in README — [GitHub](https://github.com/oeg-upm/fair_ontologies); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/oeg-upm/fair_ontologies/releases)

**ROBOT and ODK**
- `ontodev/robot`: 328 stars, BSD-3-Clause, v1.9.10 (2026-02-18), pushed 2026-10-01; README shows `docker build --tag robot:latest .` — [GitHub](https://github.com/ontodev/robot); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/ontodev/robot/releases)
- Official image `obolibrary/robot` tags v1.9.10 and latest (2026-03-10), v1.9.8 (2025-05-29) — [Docker Hub tags](https://hub.docker.com/v2/repositories/obolibrary/robot/tags)
- ROBOT `reason` supports ELK (default), HermiT, JFact, Whelk, EMR and Structural — [robot.obolibrary.org/reason](https://robot.obolibrary.org/reason)
- `INCATools/ontology-development-kit`: 385 stars, BSD-3-Clause, v1.6.1 (2026-03-10), pushed 2026-10-09; images `obolibrary/odklite` (essential tools) and `obolibrary/odkfull` (ROBOT, owltools, dosdp-tools "and many more") — [GitHub](https://github.com/INCATools/ontology-development-kit); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/INCATools/ontology-development-kit/releases); Docker Hub `obolibrary/odkfull` tags latest/v1.6.1 (2026-03-10), dev (2026-07-17); "Requires Docker Desktop 4.37.1 or later" — [Docker Hub tags](https://hub.docker.com/v2/repositories/obolibrary/odkfull/tags); [Docker Hub page](https://hub.docker.com/r/obolibrary/odkfull); ODK paper (Database 2022) — [arXiv 2207.02056](https://export.arxiv.org/abs/2207.02056)
- WebProtégé's `webprotege-robot-service` wraps ROBOT as a Spring Boot microservice (pushed Feb 2026) — [protegeproject repos](https://github.com/orgs/protegeproject/repositories?q=webprotege&type=all&sort=pushed)

**Reasoners as a service**
- Konclude: `konclude/Konclude` 53 stars, LGPLv3, last push 2022-05-14, newest changelog entry v0.7.0-1138; Docker Hub `konclude/konclude` latest = v0.7.0-1138 pushed 2021-06-19; modes `owllinkserver` (OWLlink over HTTP, `-p`, default 8080) and `sparqlserver` (SPARQL over HTTP POST) — [GitHub](https://github.com/konclude/Konclude); [Docker Hub tags](https://hub.docker.com/v2/repositories/konclude/konclude/tags); [Debian man page](https://dyn.manpages.debian.org/trixie/konclude/Konclude.1.en.html)
- Owlery: `phenoscape/owlery` 17 stars, MIT, "REST web services which allow querying of an OWL reasoner containing a configured set of ontologies"; v0.17.2 (2022-02-17), pushed 2024-08-13; Docker `phenoscape/owlery` latest 2022-02-17; HOCON `application.conf` with `kbs` list (`name`, `location`, `reasoner` e.g. `hermit`), port 8080 — [GitHub](https://github.com/phenoscape/owlery); [Docker Hub tags](https://hub.docker.com/v2/repositories/phenoscape/owlery/tags); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/phenoscape/owlery/releases)
- Openllet: `Galigator/openllet` 135 stars, last release 2.6.5 (2019-09-27), pushed 2025-08-04; modules core/jena/owlapi/query/pellint/profiler/protege plugin; no HTTP server or Docker in README — [GitHub](https://github.com/Galigator/openllet); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/Galigator/openllet/releases)
- ELK: `liveontologies/elk-reasoner` 128 stars, Apache-2.0, v0.6.0 (2024-05-25), pushed 2026-06-13 (library/Protégé plugin, no server) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/liveontologies/elk-reasoner/releases)
- Whelk (OWL EL, Scala): `INCATools/whelk` 46 stars, BSD-3, v1.2.1 (2024-09-30), pushed 2025-03-05 — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/INCATools/whelk/releases)
- owlready2 (bundles HermiT/Pellet, needs Java): PyPI 0.51 (2026-06-22) — [PyPI JSON](https://pypi.org/pypi/owlready2/json)
- No HermiT/Openllet/ELK Docker images were found by Docker Hub search — [search hermit](https://hub.docker.com/v2/search/repositories/?query=hermit), [openllet](https://hub.docker.com/v2/search/repositories/?query=openllet)
- `comunica/comunica-feature-reasoning` is archived — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/comunica/comunica-feature-reasoning)

**SHACL validation services**
- pySHACL: `RDFLib/pySHACL` 357 stars, Apache-2.0, v0.40.1 (2026-07-28); server needs `pip install pyshacl[http]`, run `pyshacl --server` or set `PYSHACL_SERVER=TRUE`; default `127.0.0.1:8099`, override with `PYSHACL_SERVER_LISTEN`, `PYSHACL_SERVER_PORT`, `PYSHACL_SERVER_HOSTNAME`; OpenAPI docs at `/docs`; image `docker.io/ashleysommer/pyshacl:latest`; SHACL-JS optional (`-j`), inference `none|rdfs|owlrl|both` via OWL-RL — [GitHub](https://github.com/RDFLib/pySHACL); [PyPI JSON](https://pypi.org/pypi/pyshacl/json); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/RDFLib/pySHACL/releases)
- Docker Hub `ashleysommer/pyshacl`: latest pushed 2024-12-16 (v0.29.1), newest tag v0.30.1 (2025-03-14) — i.e. the image lags PyPI 0.40.1 by ten minor versions — [Docker Hub tags](https://hub.docker.com/v2/repositories/ashleysommer/pyshacl/tags)
- `SDM-TIB/shaclAPI` (SHACL-over-SPARQL optimisation API): 5 stars, GPL-3.0, v0.13.0 (2026-06-17); locally built image, `POST` validation route — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/SDM-TIB/shaclAPI/releases); [PyPI shaclapi](https://pypi.org/project/shaclapi/0.10.0)
- `zazuko/rdf-validate-shacl` (JS engine under SHACL Playground): 125 stars, v0.6.5 (2025-05-30) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/zazuko/rdf-validate-shacl/releases)
- RDFUnit: `AKSW/RDFUnit` 165 stars, Apache-2.0, last release v0.7.4 (2015-06-30), pushed 2025-09-18; "A Dockerfile is provided to create a Docker image of the CLI" (`docker build -t rdfunit .`), build badge still points to travis-ci.org — [GitHub](https://github.com/AKSW/RDFUnit); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/AKSW/RDFUnit/releases)

**ShEx validators**
- shex.js: `shexjs/shex.js` 62 stars, MIT, pushed 2026-10-04; last GitHub release v1.0.1 (2018) but npm `@shexjs/validator` and `@shexjs/webapp` are at 1.0.0-alpha.33 (2026-09-14); browser validator `shex.html` self-hostable by serving the repo root or `npx shex-serve`; hosted at shex.io — [GitHub](https://github.com/shexjs/shex.js); [npm validator](https://registry.npmjs.org/@shexjs/validator); [npm webapp](https://registry.npmjs.org/@shexjs/webapp)
- rudof: `rudof-project/rudof` 131 stars, Apache-2.0 OR MIT, releases 0.3.10 (2026-08-21), 0.3.9, 0.3.8, pushed 2026-10-09; ShEx + SHACL validation, DCTAP, conversions between formalisms, SPARQL querying, PGSchema; Docker `angelip2303/rudof:latest`; Python bindings `pyrudof`; `rudof shex-validate` has `--endpoint` input — [GitHub](https://github.com/rudof-project/rudof); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/rudof-project/rudof/releases); [Debian man page](https://dyn.manpages.debian.org/trixie/rudof/rudof-shex-validate.1); PyPI `rudof` (old crate wrapper) last 0.1.12 on 2024-08-13 — [PyPI JSON](https://pypi.org/pypi/rudof/json)
- PyShEx: PyPI `pyshex` 0.9.0 uploaded 2026-05-07, licence CC0 — [PyPI JSON](https://pypi.org/pypi/pyshex/json) (GitHub repo not resolvable under `hsolbrig/PyShEx` via ecosyste.ms; see Gaps)
- RDFShape (WESO): `weso/rdfshape-api` 36 stars, MIT, v0.2.12 (2022-05-12), pushed 2024-07-10; `weso/rdfshape-client` pushed 2024-04-23 — [ecosyste.ms api](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/weso/rdfshape-api), [client](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/weso/rdfshape-client)
- Newer Rust engine with SHACL+ShEx: `Blackcat-Informatics/purrdf` ("one RDF 1.2 engine… in Rust, Python, WebAssembly and C"), 48 stars, Apache-2.0, created 2026-07-01, rust-v3.0.1 (2026-10-03) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/Blackcat-Informatics/purrdf/releases)

**Ontology change-management (new category)**
- `fabio-rovai/open-ontologies`: 920–1,100 stars, MIT, Rust, created 2026-03-09, v2.0.0 (2026-09-21); "Plan, apply and roll back changes to a production ontology, with a blast radius report and a proof an auditor can check"; README: "This is not an ontology editor"; single binary + MCP server, Oxigraph 0.5, Lean 4 proof checkers, Tauri "Studio"; image `ghcr.io/fabio-rovai/open-ontologies:latest` — [GitHub](https://github.com/fabio-rovai/open-ontologies); [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/fabio-rovai/open-ontologies/releases)

### Inferences
- A "validation sidecar" trio that is low-risk to add: pySHACL server (build from PyPI 0.40.x rather than the stale Docker Hub tag; port 8099), rudof (official image, ShEx/SHACL/DCTAP CLI), and FOOPS! (build JAR, run on a free port such as 8089). OOPS! requires a Tomcat WAR build or the community image.
- ROBOT/ODK fit as compose `profiles` or `docker run` one-shots (CLI tools, not servers); ODK full image is large (bundled JVM tools), so odklite or `obolibrary/robot` is preferable for a dev stack.
- No maintained HTTP reasoner exists: Konclude's image (2021) still works for OWL 2 DL via OWLlink/SPARQL, Owlery (2022) wraps HermiT/OWL API via REST; both should be labelled "legacy but functional". OntoInk's bundled reasoning (HermiT via owlready2, Konclude-WASM) is the only 2026-maintained route to in-browser/CI reasoning found.

### Gaps
- PyShEx's current GitHub home was not located (ecosyste.ms 404 for `hsolbrig/PyShEx`); only PyPI data is cited.
- Owlery's supported reasoner list beyond `hermit` was not confirmed from the README.
- OOPS! licence conflict (README says Apache-2.0; ecosyste.ms records none) — check the `LICENSES/` directory.
- No source was found that the pySHACL Docker image's `latest` will be rebuilt for 0.40.x.

---

## Key question 5: What is new or notable in 2025–2026

### Takeaway
The notable 2025–2026 developments are: WebProtégé's microservice re-architecture becoming deployable via `webprotege-deploy` (2026 releases of every service); Skosmos 3.0 (Dec 2025) with a rewritten frontend and quarterly 3.x releases through Aug 2026; VocBench 15.1 (May 2026) and its GraphDB 11 licensing caveat; OLS4 4.0.x on PostgreSQL+pgvector with an MCP endpoint; a wave of new lightweight editors/tools (OrionBelt Nov 2025, RDFArchitect Feb 2026, ProtegeDesk, open-ontologies Mar 2026, purrdf Jul 2026); and research tools OntView (Jul 2025) and OntoInk (ISWC 2026 companion, Oct 2026). Accepted-paper lists for the ISWC 2025 / ESWC 2026 resource tracks and practitioner LinkedIn posts could not be retrieved.

### Cited Findings
- Protégé Desktop 5.6.9 released 2026-03-07 (5.6.8 on 2025-09-03) — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/protegeproject/protege/releases)
- WebProtégé microservice components had releases in July 2026 (backend 5.0.17, gwt-ui 9.0.25, keycloak 2.0.3) and new 2025–2026 repos (`webprotege-nginx` created 2026-04-17, `webprotege-robot-service`, `webprotege-gh-*` GitHub integration services, `webprotege-user-migration-tool`) — [protegeproject repos](https://github.com/orgs/protegeproject/repositories?q=webprotege&type=all&sort=pushed); [ecosyste.ms nginx](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/protegeproject/webprotege-nginx)
- Skosmos v3.0 (2025-12-10) → v3.4 (2026-08-31); "first alpha version of Skosmos 3… reimplemented front-end with a fresh layout and improved accessibility" — [ecosyste.ms](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/NatLibFi/Skosmos/releases); [SWIB forum post](https://forum.swib.org/t/from-chaos-to-skosmos-publishing-controlled-vocabularies-made-easy/1454)
- VocBench 15.1 (2026-05-07) and 15.1.2 (2026-07-16); GraphDB ≥11 free tier limited to 5 repositories — [Interoperable Europe](https://interoperable-europe.ec.europa.eu/collection/semic-support-centre/solution/vocbench/releases); [vocbench-user](https://groups.google.com/g/vocbench-user/c/pjIfpsgPC3E)
- OLS4: paper "OLS4: A new Ontology Lookup Service for a growing interdisciplinary knowledge ecosystem" (arXiv 2501.13034, Jan 2025); README now documents PostgreSQL+pgvector and an MCP server at `https://www.ebi.ac.uk/ols4/api/mcp`; releases v4.0.1–v4.0.3 in October — [arXiv](https://arxiv.org/abs/2501.13034v1); [dev README](https://github.com/EBISPOT/ols4/blob/dev/README.md); [releases](https://github.com/EBISPOT/ols4/releases)
- OntoInk: arXiv 2610.05945 submitted 5 Oct 2026 for the ISWC 2026 Companion Volume; PyPI 0.7.9 on 2026-10-08 — [arXiv](https://arxiv.org/html/2610.05945); [PyPI](https://pypi.org/pypi/ontoink/json)
- OntView: arXiv 2507.13759, 18 Jul 2025 — [arXiv](https://arxiv.org/abs/2507.13759)
- New tools created in the last 12 months: OrionBelt (created 2025-11-25, 215 stars, Docker Hub image), ProtegeDesk (2025-12-30), RDFArchitect (2026-02-17), open-ontologies (2026-03-09, ~1k stars in 7 months), purrdf (2026-07-01) — [ecosyste.ms OrionBelt](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/ralforion/orionbelt-ontology-builder), [ProtegeDesk](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/aadorian/ProtegeDesk), [RDFArchitect](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/SOPTIM/RDFArchitect), [open-ontologies](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/fabio-rovai/open-ontologies), [purrdf](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/Blackcat-Informatics/purrdf)
- GitHub topic `ontology-editor` (by update) is dominated by OrionBelt (216 stars, updated 2026-10-14) and ProtegeDesk — [GitHub topic](https://github.com/topics/ontology-editor?o=desc&s=updated)
- Graph visualisation libraries kept releasing: Reactodia v0.32–0.35 (Mar–Jul 2026), Zazuko graph-explorer v2.0.0/2.0.1 (2026-07-21), AWS graph-explorer v3.1.0 (2026-06-10), Sparnatural 13.x (2026) — [Reactodia](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/reactodia/reactodia-workspace/releases), [zazuko](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/zazuko/graph-explorer/releases), [aws](https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/aws/graph-explorer/releases), [Sparnatural npm](https://registry.npmjs.org/sparnatural)
- Shapes ecosystem: SHACL Play 0.12.x (Apr–Jun 2026), shacl-form 3.7.4 (Oct 2026), rudof 0.3.10 (Aug 2026), pySHACL 0.40.1 (Jul 2026), TopQuadrant SHACL 1.5.0 (Mar 2026), ShapeThing NLnet project (2026-03), SHACL UI spec editor change (Sept 2025) — sources as cited in Q1/Q4
- OBO tooling: ROBOT 1.9.10 (Feb 2026), ODK 1.6.1 (Mar 2026), OAK 0.7.4 (Aug 2026) — sources as cited in Q4
- ESWC 2026 (Dubrovnik, 10–14 May 2026) resource track "received 63 submissions of which 17 have been accepted" — [Springer proceedings](https://link.springer.com/book/9783032251589); ISWC 2025 resource track chairs Cogan Shimizu and Angelo Salatino, notifications 2025-07-17 — [ISWC 2025 CfP via X](https://x.com/iswc_conf/status/1882071483792711790)
- A 2026 vendor roundup of "ontology management tools" lists commercial TopBraid EDG and Metaphactory as enterprise options (vendor-authored) — [OvalEdge blog](https://www.ovaledge.com/blog/ontology-management-tools); an ontolog-forum thread on "alternatives to Protege and Vocbench" suggests WebProtégé as the cloud option — [ontolog-forum](https://groups.google.com/g/ontolog-forum/c/z3acfaYO6wc)
- Usability research on front-end ontology tooling (arXiv 2608.07491, Aug 2026) and LLM-driven extension (OntoExtend, arXiv 2607.17963) exist but are papers, not deployable tools — [arXiv 2608.07491](https://arxiv.org/pdf/2608.07491); [arXiv 2607.17963](https://arxiv.org/pdf/2607.17963)

### Inferences
- The centre of gravity in 2025–2026 moved toward (1) SHACL-first tooling and (2) "docs-as-code"/MkDocs and MCP/LLM integration (OLS4 MCP, open-ontologies MCP, ProtegeDesk LLM features), rather than new VOWL-style visualisers.
- Star velocity of open-ontologies (~1k in 7 months) and OrionBelt (215 in 11 months) suggests community appetite for Java-free ontology tooling; both are single-maintainer-looking projects, so pin versions.

### Gaps
- Accepted-paper lists for ISWC 2025 and ESWC 2026 resource tracks were not retrieved (conference pages 404/SPA); no tool could be attributed to those tracks except OntoInk (ISWC 2026 companion per its arXiv page).
- No LinkedIn or Reddit practitioner recommendations were found; the search budget ran out before targeted queries could be run.
- SEMANTiCS 2025 tool announcements not checked (search budget exhausted).

---

## Appendix: quick adoption table (ports chosen to avoid 3030/3333/7001/7333/8082–8088)

| Tool | Image / build | Suggested host port | Licence | Latest version (date) | Risk notes |
|---|---|---|---|---|---|
| pyLODE server | build from `RDFLib/pyLODE` Dockerfile (`pylode-server` target, :8000) | 8090 | BSD-3 | 3.6.0 (2026-08-17 PyPI) | Dockerfile in repo; no official registry image |
| WIDOCO (CLI) | `ghcr.io/dgarijo/widoco` | n/a (one-shot) | Apache-2.0 | v1.4.25 (2024-06-30) | Java 8+; CLI only |
| SHACL Play | `docker build` from `sparna-git/shacl-play` (:8080) | 8091 | LGPL-3.0 | 0.12.1 (2026-06-15) | no registry image |
| pySHACL server | `ashleysommer/pyshacl` or build from PyPI (`PYSHACL_SERVER=TRUE`, :8099) | 8099 | Apache-2.0 | 0.40.1 (2026-07-28) | Hub tag lags (v0.30.1, 2025-03) |
| rudof | `angelip2303/rudof:latest` | n/a (CLI) | Apache-2.0/MIT | 0.3.10 (2026-08-21) | — |
| FOOPS! | build JAR (JDK 11), `-Dserver.port` | 8089 | Apache-2.0 | v0.4.0 (2026-05-04) | README example uses 8083 (taken); needs internet for URI tests |
| OOPS! | `mpovedavillalon/oops:v2` (community) or WAR on Tomcat 10 | 8092 | Apache-2.0 (README) | 0.2.0 (2025-06-24) | community image |
| ROBOT / ODK | `obolibrary/robot:v1.9.10`, `obolibrary/odklite` | n/a (CLI) | BSD-3 | 1.9.10 / ODK 1.6.1 (2026-02/03) | large images |
| AWS graph-explorer | `public.ecr.aws/neptune/graph-explorer:latest` (:80/:443) | 8093 | Apache-2.0 | v3.1.0 (2026-06-10) | self-signed HTTPS by default |
| Skosmos | `quay.io/natlibfi/skosmos:latest` + Fuseki (JenaText) + Varnish | 9090 | MIT | v3.4 (2026-08-31) | wants its own Fuseki on 3030/9030 |
| OLS4 | compose from `EBISPOT/ols4` (postgres, backend, frontend :8081) | 8081 → remap | Apache-2.0 | v4.0.3 (Oct, year unverified) | dataload step before `up`; no reasoning |
| OntoInk | `pip install ontoink` in an MkDocs container (Dockerfile in repo) | 8094 | MIT | 0.7.9 (2026-10-08) | tiny community; reasoner backends need Java/Konclude |
| OrionBelt | `ralforion/orionbelt-ontology-builder` (:8501) | 8501 | BSL-1.1 (→Apache-2.0 2030) | v1.27.8 (2026-09-22) | not OSI-open until 2030 |
| RDFArchitect | compose from `SOPTIM/RDFArchitect` (`docker/`, :3000) | 3000 → remap | Apache-2.0 | v1.6.0 (2026-09-10) | RDFS/CIM focus, Java 25 |
| WebProtégé NG | compose from `protegeproject/webprotege-deploy` (~14 services) | 80/8080 → remap | BSD-2 (deploy) | backend 5.0.17 (2026-07-27) | Keycloak, MongoDB, RabbitMQ, MinIO, custom hostname |
| VocBench 3 | `ternau/vocbench3:13.0.0` (community) or build from 15.1.2 standalone | 1979 | "free and open source" (exact licence unverified) | 15.1.2 (2026-07-16) | no official image; GraphDB/RDF4J oriented |
| Konclude | `konclude/konclude` (`owllinkserver`/`sparqlserver` -p 8080) | 8095 | LGPL-3 | v0.7.0-1138 (image 2021-06-19) | unmaintained since 2022 |
| Owlery | `phenoscape/owlery` (:8080, HOCON config) | 8096 | MIT | v0.17.2 (2022-02-17) | unmaintained since 2024 |
| Chowlk | compose from `oeg-upm/chowlk` `webservice` branch (:5000) | 5000 → remap | Apache-2.0 | v0.0.1 tag; last push 2025-04-11 | low activity |
