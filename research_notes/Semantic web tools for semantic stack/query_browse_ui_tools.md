# Query, exploration, browsing, search and vocabulary-management UIs for an RDF/SPARQL Docker Compose stack (state as of 2026-10-14)

Scope note: the target stack (MetaCoding-io/semantic-stack) already ships QLever (+ QLever UI), Fuseki, Oxigraph, RDF4J Workbench, OntoRefine, OpenRefine, RML Mapper, WebVOWL, Trifid (+ graph-explorer), Blueprint, YASGUI and Comunica. Those are not re-recommended below; they are only mentioned where a candidate depends on or overlaps with them.

Method note: GitHub star counts, "pushed" dates, licences and archived flags below come from the GitHub repository metadata returned by the GitHub search API on 2026-10-14 (the per-repo API and `gh` were blocked in this session, so figures are from `search/repositories` results). Release dates come from each repo's `releases.atom` feed (ISO timestamps) unless stated otherwise. Where GitHub shows `NOASSERTION` for the licence, the licence file exists but GitHub could not classify it; the README-stated licence is given where found. Everything marked "unverified" could not be confirmed from a primary source in this session.

## Key question 1: Visual / faceted / natural-language query builders and GraphQL layers over SPARQL

### Takeaway
Sparnatural (SHACL-configured, very active, LGPL) and Sparklis (NL-guided, Apache, official Docker image) are the two mature, store-agnostic visual query builders; both are pure browser apps that need a CORS-enabled endpoint (or a proxy). Sampo-UI (MIT, v4.0.0 Sept 2026, has compose) and Rhizomer (GPL, added a QLever server type in Aug 2025) cover faceted search. For GraphQL, the only actively maintained open-source options are the Comunica/rubensworks GraphQL-LD stack (library-level) and the pre-1.0 Metabase SPARQL driver (dashboards); HyperGraphQL and GraphSPARQL are effectively dormant.

### Cited Findings

Sparnatural (Sparna)
- Repo: https://github.com/sparna-git/Sparnatural — "visual knowledge graph explorer with SPARQL, in the browser, configurable with SHACL"; LGPL-3.0; 313 stars; last push 2026-10-13; homepage http://sparnatural.eu — [GitHub search metadata](https://github.com/sparna-git/Sparnatural)
- Releases (ISO dates): 13.1.0 2026-09-24; 13.0.0-beta3 2026-07-06; 13.0.0-beta 2026-06-11 ("+ info", more than 3 values, new JSON query format); 12.2.0 2026-03-25; 12.1.0 2026-03-02; 12.0.0 2025-09-23 (new query JSON format); 11.1.2 2025-07-29; 11.0.3 2025-05-26 — [releases.atom](https://github.com/sparna-git/Sparnatural/releases.atom)
- 13.1.0 adds a templating mechanism to customise dropdown lists, autocomplete and trees (issue #804); 13.0.0-beta adds a "+info" button driven by `dash:propertyRole dash:KeyInfoRole` — [13.1.0 release](https://github.com/sparna-git/Sparnatural/releases/tag/13.1.0); [releases page](https://github.com/sparna-git/Sparnatural/releases)
- Configuration is written in SHACL (editable via an Excel spreadsheet); OWL-based configuration is deprecated; docs cover the `<spar-natural>` web component, React integration, federated queries, named graphs, multiple endpoints and a GraphDB Lucene connector; a "Using a SPARQL proxy" page covers endpoints without CORS and http/https mismatches — [docs.sparnatural.eu](https://docs.sparnatural.eu/)
- README (npm 11.1.0): "the SPARQL endpoint needs to allow Cross-Origin Resource Sharing (CORS)" when on a different domain; a SPARQL proxy is offered for endpoints without CORS; since 9.0.0 SHACL is the preferred configuration — [unpkg README](https://unpkg.com/sparnatural@11.1.0/README.md)
- npm `sparnatural` dist-tag latest = 13.1.0 — [registry.npmjs.org/sparnatural](https://registry.npmjs.org/sparnatural)
- No official Docker image found: the docs index does not mention Docker, and a web search for a Sparnatural Docker image returned nothing relevant — [docs.sparnatural.eu](https://docs.sparnatural.eu/); [search](https://hub.docker.com/u/sprana)
- Used in production by the BnF (data.bnf.fr) with documentation on "Sparql and Sparnatural" — [data.bnf.fr](https://data.bnf.fr/en/sparql_sparna_doc)

Sparklis (Sébastien Ferré)
- Repo: https://github.com/sebferre/sparklis — "query builder in natural language that allows people to explore and query SPARQL endpoints"; Apache-2.0; 53 stars; last push 2025-08-09 — [GitHub metadata](https://github.com/sebferre/sparklis)
- Client-side only (OCaml compiled to JS via js_of_ocaml); can be copied as static files or run as a Docker container `sferre/sparklis:latest` on port 8080; full UI at `/osparklis.html`; root path gives a reduced UI accepting `title` and `endpoint` URL parameters; the endpoint must be CORS-enabled and reachable from the user's browser; works with any SPARQL 1.1 endpoint (Fuseki and localhost stores mentioned), better with RDFS/OWL class/property/label declarations; UI in EN/FR/ES/NL — [README](https://github.com/sebferre/sparklis)
- Last commits: 2025-06-20 "[html] switching endpoints from HTTP to HTTPS", 2025-06-02 bug fixes — [commits feed](https://github.com/sebferre/sparklis/commits/master.atom)
- A geovistory fork packages it with bitnami/nginx and Docker build actions (last updated ~3 years ago) — [ecosystem.code.gouv.fr listing](https://ecosystem.code.gouv.fr/hosts/GitHub/repositories/geovistory%2Fsparklis/dependencies)
- Peer-reviewed description: "Sparklis: An Expressive Query Builder for SPARQL Endpoints with Guidance in Natural Language", Semantic Web Journal — [SWJ](https://semantic-web-journal.net/content/sparklis-expressive-query-builder-sparql-endpoints-guidance-natural-language-1)

Rhizomer (RhizomerEye + RhizomerAPI)
- RhizomerEye: "Client part of the new version of the Rhizomer faceted browser and visualization tool"; GPL-3.0; 20 stars; last push 2025-08-05; Angular; repo has Dockerfile, docker-compose.yml, docker-compose.aws.yml — [GitHub](https://github.com/rhizomik/rhizomerEye)
- RhizomerAPI commits on 2025-08-05 include "Add QLEVER SPARQL server type" and "For QLever add ms time unit to endpoint timeout" — [commits feed](https://github.com/rhizomik/rhizomerAPI/commits/master.atom)
- Docker deployment: images `rhizomik/rhizomer-api` and `rhizomik/rhizomer-eye` on Docker Hub; ports 80 (frontend) and 8080 (API); optional MariaDB (3306) for persistent dataset config; env vars `API_URL`, `ALLOWED_ORIGINS`/`CLIENT_URL`, `RHIZOMER_DEFAULT_PASSWORD`, `SPRING_PROFILES_ACTIVE=production`, `DATABASE_URL/USERNAME/PASSWORD`; after logging in as `admin` you create a dataset pointing at the SPARQL endpoint; wiki also has "Deploy Fuseki and Rhizomer" and "Deploy Neptune and Rhizomer" pages — [RhizomerAPI wiki: Deploy using Docker](https://github.com/rhizomik/rhizomerAPI/wiki/Deploy-using-Docker)

Sampo-UI (Aalto SeCo)
- "A framework for building user interfaces for semantic portals"; MIT; 51 stars; last push 2026-09-23 — [GitHub metadata](https://github.com/SemanticComputing/sampo-ui)
- Tags: v4.0.0 2026-09-16, v3.1.0 2026-09-09 — [tags feed](https://github.com/SemanticComputing/sampo-ui/tags.atom)
- Repo includes `Dockerfile`, `compose.yaml` (dev) and `compose-prod.yaml`; version 4 is a major refactor, v3 lives on `legacy-v3` — [README](https://github.com/SemanticComputing/sampo-ui)
- compose.yaml: `client` on 8080:8080, `server` on 3001:3001 (health check `GET /health`); server env `SPARQL_ENDPOINT` and `SPARQL_ENDPOINT_BASIC_AUTH` (no defaults) — [compose.yaml](https://raw.githubusercontent.com/SemanticComputing/sampo-ui/master/compose.yaml)
- Declarative: "The UI is created declaratively by modifying a set of JSON configuration files"; faceted search plus visualisations; data accessed only through the SPARQL API — [SSH Open Marketplace](https://marketplace.sshopencloud.eu/tool-or-service/7j4LHr); [SWJ paper](https://www.semantic-web-journal.net/content/sampo-ui-full-stack-javascript-framework-developing-semantic-portal-user-interfaces-0)
- SEMANTiCS 2025 demo "How to Add a User Interface on Top of an External SPARQL Endpoint: Case Nobel Prize Sampo" (Vienna, Sept 2025) — [CEUR Vol-4064 PD-paper17](https://ceur-ws.org/Vol-4064/PD-paper17.pdf)

LD-Explorer (GCHQ)
- "LD-Explorer is the missing tool for exploring, federating and querying linked data resources directly in the browser"; Apache-2.0; 26 stars; last push 2026-10-12 — [GitHub metadata](https://github.com/gchq/LD-Explorer)
- Built on Comunica, SvelteKit/TypeScript; runs entirely in the browser; hosted at gchq.github.io/LD-Explorer; Dockerfile included, served via nginx on port 8080; loads RDF by URL/paste, named graphs, prebuilt exploration queries, federated SPARQL across active sources, CONSTRUCT results saved to local sources, SHACL testing; sources persist only in memory; Node >= 18.15 for dev — [README](https://github.com/gchq/LD-Explorer)
- Recent commits: 2026-10-05 "make graph querying optional (#281)", dependency bumps 2026-10-12 — [commits feed](https://github.com/gchq/LD-Explorer/commits/main.atom)

Wikidata Query Builder
- `wmde/query-builder` is archived and "MOVED TO https://gerrit.wikimedia.org/r/admin/repos/wikidata/query-builder"; BSD-3-Clause; last push 2021-03-19 — [GitHub metadata](https://github.com/wmde/query-builder)
- Wikidata-style queries rely on Blazegraph-specific SERVICE extensions (label service, MWAPI) that "can't be run outside of Blazegraph"; self-hosting uses `wikibase/wdqs` + `wikibase/wdqs-frontend` images — [W3C LOD list](https://lists.w3.org/Archives/Public/public-lod/2023Jan/0003.html); [Docker Hub wdqs](https://hub.docker.com/r/wikibase/wdqs)

RDF Explorer (Hogan et al.)
- Visual SPARQL query builder for non-experts; usability study over Wikidata (IJCAI 2020 extended abstract) — [demo paper](https://www.aidanhogan.com/docs/rdf_explorer_demo.pdf); [IJCAI 2020](https://www.ijcai.org/proceedings/2020/666)

GraphQL layers
- HyperGraphQL: Apache-2.0; 170 stars; last push 2022-07-25; README notes v3.0.1 as a Log4Shell mitigation; maintained by Epeirogenic AB — [GitHub](https://github.com/hypergraphql/hypergraphql)
- GraphQL-LD.js (rubensworks): MIT; 121 stars; last push 2026-08-18 — [GitHub metadata](https://github.com/rubensworks/GraphQL-LD.js); npm `graphql-ld` latest 2.0.0 published 2025-01-09 — [npm registry](https://registry.npmjs.org/graphql-ld)
- graphql-to-sparql.js: MIT; 116 stars; last push 2026-07-16 — [GitHub metadata](https://github.com/rubensworks/graphql-to-sparql.js)
- Comunica describes itself as querying with "both SPARQL and GraphQL" — [comunica.dev](https://comunica.dev/)
- GraphSPARQL (GraphQL-to-SPARQL bridge, C#): GPL-3.0; 24 stars; last push 2022-02-09; published at SAC 2022 — [GitHub metadata](https://github.com/meitinger/GraphSPARQL); [paper](https://edepot.wur.nl/571388)
- oxirs-gql (Rust GraphQL server over RDF, v0.4.1 on docs.rs) — version/date unverified — [docs.rs](https://docs.rs/crate/oxirs-gql/)
- SPARQL Transformer (D2KLab): JSON/JSON-LD template-shaped queries to any SPARQL endpoint (option `endpoint`); Apache-2.0; 47 stars; last push 2026-10-13; the README never mentions GraphQL — [GitHub](https://github.com/D2KLab/sparql-transformer)
- LDkit: "ORM-like abstraction over RDF datasources" for TypeScript; MIT; 83 stars; last push 2026-10-13; a library, not a UI — [GitHub](https://github.com/karelklima/ldkit)
- awesome-semantic-web GraphQL section also lists semantic-graphql, UltraGraphQL and dbcls/grasp — [awesome-semantic-web README](https://raw.githubusercontent.com/semantalytics/awesome-semantic-web/master/README.md)

Metabase SPARQL driver (BI dashboards; visual query builder over SPARQL)
- "Turn any SPARQL endpoint into Metabase charts, maps and dashboards"; RDF classes become tables, properties columns; AGPL-3.0; 16 stars; Docker image `ghcr.io/jhisse/metabase-sparql-driver:latest` (official Metabase image with driver included) or drop `sparql.metabase-driver.jar` into `plugins/`; any SPARQL 1.1 endpoint; demo uses Oxigraph; SHACL-based schema option; CONSTRUCT/DESCRIBE unsupported, only left joins, some aggregations missing; built against Metabase v0.61.2 — [README](https://github.com/jhisse/metabase-sparql-driver)
- Releases: 0.0.18 2026-10-06 (multi-arch Docker image), 0.0.17 and 0.0.16 2026-10-01 (SPARQL portability fixes across endpoints) — [releases.atom](https://github.com/jhisse/metabase-sparql-driver/releases.atom)

### Inferences
- For the stack, Sparnatural and Sparklis are the lowest-friction additions: both are static bundles that can be served by any nginx container and pointed at `http://localhost:<port>/sparql` of QLever/Fuseki/Oxigraph, provided CORS is enabled on those services (or Trifid/sparql-proxy is placed in front). Sparnatural's SHACL config means the stack would need a per-dataset config file; Sparklis works unconfigured.
- Rhizomer is the only faceted browser found that explicitly added QLever support (Aug 2025); it needs its own API container (+ optional MariaDB), so it is heavier than Sparnatural/Sparklis but has official images.
- Sampo-UI is a framework rather than a drop-in app; it is a good fit only if the stack wants a demo portal with a JSON config per dataset.
- HyperGraphQL would be the easiest "GraphQL over any endpoint" server to containerise (Java, config JSON) but has not been pushed since 2022; GraphQL-LD is library-level and best exposed via Comunica, which the stack already ships.
- The Metabase driver is the most "practitioner-friendly" GraphQL-free alternative for non-SPARQL users and is actively released (Oct 2026), but it is pre-1.0 and AGPL.

### Gaps
- No official Sparnatural Docker image was found; a docker-compose recipe would have to be written (serve `hello-sparnatural` or an npm build via nginx).
- Whether Rhizomer's generic dataset configuration works against Oxigraph was not verified (only Fuseki, Neptune and the new QLever type are documented).
- The ESWC 2025 "user-friendly SPARQL query editor powered by lightweight metadata" demo was only seen as a satellite-listing snippet; no repo was located.
- SemFacet successors: no maintained successor was found.

## Key question 2: Linked Data browsers / dereferencing front-ends and graph visualisation over SPARQL

### Takeaway
LodView (the classic Pubby successor) is unmaintained since 2017/2023 but still has a working community Docker image; the actively maintained alternatives are LDView (Python, Codeberg, 2026, embeds YASGUI and reads from a configurable SPARQL endpoint), RickView (Rust, 9.7 MB image, but file-based rather than endpoint-based) and the much heavier LinkedDataHub (Apache, v6.1.0 Oct 2026, bundles Fuseki). For diagram-style visualisation, Reactodia (Ontodia's maintained fork, LGPL, v0.35.2 Aug 2026) has a SPARQL data provider but is a library, not an app; QLever Petrimaps is the map viewer for geospatial results.

### Cited Findings

LodView
- "IRI dereferencer, RDF to HTML"; MIT; 137 stars; last push 2023-12-17; homepage http://lodview.it — [GitHub metadata](https://github.com/LodLive/LodView)
- Last tagged release v1.2.1 ("Clone the code!") 2017-03-25; v1.2.0 2015-10-05 — [releases.atom](https://github.com/LodLive/LodView/releases.atom)
- Community image `linkeddatacenter/lodview` configured by env vars `LODVIEW_SPARQLENDPOINT`, `LODVIEW_AUTHUSERNAME/PASSWORD`, `LODVIEW_URISPACE`, `LODVIEW_PUBLICURLPREFIX` (`auto` for local testing); last updated over four years ago — [Docker Hub](https://hub.docker.com/r/linkeddatacenter/lodview)
- Alternative configuration via `lodview/conf.ttl` plus `.env` in an Ontop+LodView compose template; reverse-proxy settings must be edited there for external dereferencing — [unibz GitLab template](https://gitlab.inf.unibz.it/fracorco/ontop-lodview-docker-template/-/tree/95b63fb44d9a10a8a06a519eff8bd66cc424166c)

LodLive
- "browse the web of data - a SPARQL navigator"; MIT; 205 stars; last push 2020-04-22 — [GitHub metadata](https://github.com/LodLive/LodLive)

LDView (René Voorburg, Codeberg)
- Linked Data viewer and URI dereferencer "inspired by LodView"; Python; MIT; displays RDF from Turtle files, HDT files or SPARQL endpoints with an embedded YASGUI editor; run with `docker compose up` behind nginx (deploy/ has nginx config and systemd unit); `config.py` sets `RDF_DATA_SOURCE_TYPES = ['sparql']` and `SPARQL_ENDPOINT = ...`, fallback chains like `['turtlefiles','sparql']`, and `URI_SPARQL_ENDPOINT_MAPPINGS` for a URI proxy; no tagged releases; last commit 2026-08-19; 4 stars; README states it was built with significant AI assistance — [Codeberg](https://codeberg.org/renevoorburg/ldview)

RickView
- "quick RDF viewer"; lightweight standalone RDF knowledge graph browser in Rust; layout copied from LodView; MIT; 37 stars; last push 2026-09-17 — [GitHub metadata](https://github.com/KonradHoeffner/rickview)
- Image `ghcr.io/konradhoeffner/rickview` (~9.7 MB), port 8080; loads a local RDF file or URL (`RICKVIEW_KB_FILE`; Turtle, N-Triples, RDF/XML, HDT, HDT.zst); "needs no SPARQL endpoint" — data comes from the file — [README](https://github.com/konradhoeffner/rickview)

LinkedDataHub (AtomGraph)
- "The low-code Knowledge Graph application platform"; Apache-2.0; 630 stars; last push 2026-10-13 — [GitHub metadata](https://github.com/AtomGraph/LinkedDataHub)
- Releases: 6.1.0 2026-10-04; 6.0.1 2026-10-04; 6.0.0 2026-09-29; 5.10.0 2026-08-30; 5.9.0 2026-08-18 … 5.6.1 2026-07-26 — [releases.atom](https://github.com/AtomGraph/LinkedDataHub/releases.atom)
- 6.1.0: `ldh` CLI drops `-b/--base`; runtime settings stored as a change set in `settings/dataspaces.ru`; release images built per architecture; 6.0.1 adds `linkeddatahub-rdf` library and fixes an SSR deadlock — [releases page](https://github.com/AtomGraph/LinkedDataHub/releases)
- Compose services: nginx, linkeddatahub, varnish, `atomgraph/fuseki`, `namshi/smtp`; Fuseki is bundled and data persists in `data`/`fuseki`; local example ports HTTP 81 / HTTPS 4443 with base URI `https://localhost:4443/`; `make up -- --build`; `config/system.trig` holds SPARQL service bindings and `secrets/credentials.trig` SPARQL auth; v6 redraws the UI on a bundled design system; v5.9.0 optional graph versioning mirrored to GitHub; v5.1.0 multiple dataspaces; CLI needs Java 21 — [README](https://github.com/AtomGraph/LinkedDataHub)
- Companion `AtomGraph/Web-Client`: "Generic Linked Data browser and UX component framework"; Apache-2.0; 123 stars; last push 2026-10-13 — [GitHub metadata](https://github.com/AtomGraph/Web-Client)
- Companion `AtomGraph/Web-Algebra`: "Suite of generic Linked Data/SPARQL as well as LinkedDataHub-specific MCP tools"; Apache-2.0; 46 stars; last push 2026-10-03; generic ops include GET/PATCH/POST/PUT and SPARQL CONSTRUCT/DESCRIBE/SELECT; run via `uv` as stdio or Streamable-HTTP MCP server; needs `OPENAI_API_KEY` for NL mode — [README](https://github.com/AtomGraph/Web-Algebra)

Reactodia / Ontodia
- Ontodia (metaphacts) is archived; last push 2022-12-11; 177 stars — [GitHub metadata](https://github.com/metaphacts/ontodia)
- Reactodia Workspace: "library for visual interaction with graph data in a form of a diagram"; open-source fork of Ontodia; LGPL-2.1; 36 stars; last push 2026-10-13 — [GitHub metadata](https://github.com/reactodia/reactodia-workspace)
- Releases: v0.35.2 2026-08-08; v0.35.1 2026-07-10; v0.35.0 2026-06-21 (standalone workspace state, Vite 8/TS 6); v0.34.1 2026-03-29; v0.34.0 2026-03-25 (touchscreen support; `SparqlDataProvider.lookup()` configurable via `lookupQuery` and `filterInnerPrelude`) — [releases page](https://github.com/reactodia/reactodia-workspace/releases)

QLever Petrimaps (map view)
- "Interactive visualization of SPARQL query results with geospatial information on a map, either as individual objects or as a heatmap"; Apache-2.0; 21 stars; last push 2026-09-29 — [GitHub metadata](https://github.com/ad-freiburg/qlever-petrimaps)
- `docker run --rm -p 9090:9090 adfreiburg/qlever-petrimaps:latest`; takes `?query` and `?backend` GET params; access-token backends registered via `/touch?backend=`; geometry must be the last selected column by default; README describes the backend only as a "QLever backend" — [README](https://github.com/ad-freiburg/qlever-petrimaps)

Graph visualisation / desktop / browser extensions
- Gephi Semantic Web Import plugin (Wimmics/Inria, CeCILL-C): queries local RDF via embedded Corese or a remote SPARQL endpoint; W3C wiki lists latest release 2012-06-15 "(verify)"; a user reports a silent default LIMIT 100 — [W3C wiki](https://www.w3.org/2001/sw/wiki/GephiSemanticWebImportPlugin); [gephi.org](https://gephi.org/desktop/plugins/semantic); [Stardog forum](https://community.stardog.com/t/visualization-ftw/969)
- RDF Browser Firefox add-on (Schmalenbach & Harth, FAU Erlangen): MIT; version 1.2.3, last updated Oct 2022; requests JSON-LD/N-Triples/RDF-XML/Turtle and renders Turtle with clickable links; source https://github.com/kianschmalenbach/rdf-browser — [addons.mozilla.org](https://addons.mozilla.org/addon/rdf-browser/)
- Tabulator (linkeddata/tabulator): last push 2016-08-23; 51 stars — [GitHub metadata](https://github.com/linkeddata/tabulator)
- Zazuko RDF Sketch: "Sketch RDF in the web browser with immediate visualization"; MIT; 46 stars; last push 2026-03-31 — [GitHub metadata](https://github.com/zazuko/rdf-sketch)
- Zazuko cube-viewer: "visualize RDF Cubes in SPARQL endpoints"; Vue; 3 stars; last push 2026-02-02 — [GitHub metadata](https://github.com/zazuko/cube-viewer)
- iolanta: "Browse and visualize Linked Data with Python" (textual UI); 14 stars; last push 2026-10-10 — [GitHub metadata](https://github.com/iolanta-tech/iolanta)
- Linked Data Reactor (LD-R): 133 stars; last push 2025-12-04; licence NOASSERTION — [GitHub metadata](https://github.com/ali1k/ld-r)
- Semantic Forms (jmvanel): 80 stars; last push 2023-05-09 — [GitHub metadata](https://github.com/jmvanel/semantic_forms)
- awesome-semantic-web "Browsers" section lists only Galacteek, LodView, RhizomerEye and RickView; its visualisation list adds d3-sparql, SPARQLFilterFlow, sgvizler, KinGVisher, RdfGlance and the commercial SemSpect/G.V/RDF Studio — [awesome-semantic-web](https://raw.githubusercontent.com/semantalytics/awesome-semantic-web/master/README.md)

Metaphactory community edition
- No official free/community Docker image found: AWS Marketplace lists "metaphactory for any graph database (AMI, non-production license)"; an unofficial `robcast/metaphacts-community-platform:4.1.0` image was updated almost 5 years ago — [AWS Marketplace](https://aws.amazon.com/marketplace/pp/prodview-2h6qiqogjqe2m); [Docker Hub](https://hub.docker.com/r/robcast/metaphacts-community-platform/tags)

Semantic Web Dog Food / Kaleidos
- SWDF was refactored into ScholarlyData (SPARQL + dereferencing); no "Kaleidos" linked-data browser was found in search — [w3id.org/scholarlydata](https://w3id.org/scholarlydata)

### Inferences
- A dereferencing front-end that is both maintained and endpoint-driven is a real gap in the OSS landscape; LDView (2026, Python, YASGUI embedded) is the closest drop-in, but it is a one-person prototype. LodView remains usable via `linkeddatacenter/lodview` with `LODVIEW_SPARQLENDPOINT`, but expect Java/Tomcat-era dependencies.
- Trifid (already in the stack) already covers the dereferencing use case for most needs; LodView/LDView would add the "classic Pubby look" and per-resource HTML.
- LinkedDataHub is a platform, not a browser; adding it means a second Fuseki plus nginx/varnish/smtp. Whether it can be pointed at the stack's existing Fuseki/QLever via `config/system.trig` is plausible (SPARQL service bindings are declared there) but the docs page was not reachable (403) to confirm requirements such as Graph Store Protocol support.
- Reactodia would need a small wrapper app (Vite) to become a service; it is the right choice if the stack wants an Ontodia-style diagram explorer over QLever/Fuseki.
- Petrimaps is documented only against QLever backends; treat it as a QLever-specific add-on (natural since QLever is the stack's primary store).

### Gaps
- LinkedDataHub docs for configuring an external (non-bundled) SPARQL endpoint returned HTTP 403; requirements (GSP, auth) unverified.
- Whether Petrimaps accepts a non-QLever `?backend` is undocumented.
- No metadata on Galacteek, KinGVisher or RdfGlance was collected.

## Key question 3: Full-text / search over RDF, semantic search UIs and static site generators

### Takeaway
No actively maintained generic "SPARQL endpoint to Elasticsearch/OpenSearch indexer with a search UI" was found; the practical options are store-native text indexes (Jena text/Lucene for Fuseki, QLever's `ql:contains-word` text index, RDF4J LuceneSail) plus DBpedia Lookup (Apache, generic Lucene entity search configured by SPARQL queries, docker compose, last push Feb 2025). For LLM-assisted search, SIB's sparql-llm ships a containerised chat UI + MCP server. Static-site generation from RDF is limited to jekyll-rdf (last release Feb 2023) and SkoHub Vocabs (SKOS only).

### Cited Findings
- Apache Jena text index: SPARQL `text:query` property function over Lucene; current Jena uses Lucene 9.4.x; "Solr and ElasticSearch not supported"; Elasticsearch support ended with Jena 3.17.0 (ES 6.8.6) — [Jena text query docs](https://jena.apache.org/documentation/query/text-query.html)
- RDF4J has an Elasticsearch index for its LuceneSail, with the caveat that several Elasticsearch dependencies are under the Elastic License or SSPL — [RDF4J javadoc](https://rdf4j.org/javadoc/4.3.2/org/eclipse/rdf4j/sail/elasticsearch/package-summary.html)
- EARQ (ARQ + Elasticsearch free-text) is "experimental (and unsupported)" with a known breakage in its TODO — [GitHub](https://github.com/castagna/EARQ/blob/master)
- QLever: `ql:contains-word` and `ql:contains-entity` text predicates; `qlever index` builds RDF and text index together, `qlever add-text-index` adds one later, server started with `--use-text-index`; external text supplied as wordsfile/docsfile; a 2025 Freiburg thesis improved the literal-based full-text index — [docs.qlever.dev/text-search](https://docs.qlever.dev/text-search/); [thesis](https://ad-publications.informatik.uni-freiburg.de/theses/Bachelor_Felix_Meisen_2025.pdf)
- DBpedia Lookup: "A generic entity retrieval service for linked data"; Lucene-based; indexing driven by SPARQL queries selecting key/value pairs from a KG (files or endpoint); Maven build or `docker compose up` from the `lookup` directory; API on port 8082 (`/api/index/run`, `/api/search`); Apache-2.0; 53 stars; last push 2025-02-12 — [README](https://github.com/dbpedia/dbpedia-lookup)
- OpenPhacts `ops-search-elasticsearch`: indexing configured by a SPARQL endpoint and an RDF type ("Typically one ElasticSearch type corresponds to one RDF type"); older project — [Docker Hub](https://hub.docker.com/r/openphacts/ops-search-elasticsearch/)
- OpenMetadata's RDF feature stores triples in Fuseki and uses OpenSearch vector search for its semantic-search-over-graph endpoint (product-specific) — [OpenMetadata docs](https://docs.open-metadata.org/deployment/rdf-knowledge-graph)
- OLS4 (EBI Ontology Lookup Service): README describes PostgreSQL with pgvector as the store for entities, hierarchies, embeddings and full-text search; ontologies are loaded from OWL/RDFS files via `dataload.sh` (not from a SPARQL endpoint); frontend at `localhost:8081` after `docker compose up`; MCP endpoint `/api/mcp` (stateless Streamable HTTP) — [README](https://github.com/EBISPOT/ols4); releases 4.0.3 2026-10-08, 4.0.2 2026-10-07, 4.0.1 2026-10-06 (adds MCP server, embeddings) — [releases.atom](https://github.com/EBISPOT/ols4/releases.atom); Apache-2.0; 106 stars — [GitHub metadata](https://github.com/EBISPOT/ols4)
- sparql-llm (SIB Swiss Institute of Bioinformatics): "Chat system, MCP server, and reusable components to improve LLMs capabilities when generating SPARQL queries"; MIT; 127 stars; last push 2026-10-13 — [GitHub metadata](https://github.com/sib-swiss/sparql-llm); deployment requires cloning and editing `src/sparql-llm/config.py` and `compose.yml`, `.env` with `CHAT_API_KEY`, `LOGS_API_KEY`, `OPENROUTER_API_KEY`, `OPENAI_API_KEY`; `docker compose up` (dev) or `compose.prod.yml`; chat UI/API on 8000 (Swagger at `/docs`), Qdrant on 6333/6334; endpoints listed in a JSON settings file (`SETTINGS_FILEPATH`) with `endpoint_url`; endpoints "need VoID metadata and SPARQL query examples"; "can easily be adapted to use any LLM served through an OpenAI-compatible API" — [README](https://github.com/sib-swiss/sparql-llm)
- jekyll-rdf: Ruby gem to "generate static sites with Jekyll based on RDF data", depends on linkeddata and sparql-client; latest version 4.0.4 (Feb 2023) — [RubyGems](https://rubygems.org/gems/jekyll-rdf/versions/4.0.4?locale=fr)
- SkoHub Vocabs is a static site generator for SKOS (see Q4); no Hugo/RDF integration was found in search — [search result](https://rubygems.org/gems/jekyll-rdf/versions/4.0.4?locale=fr)
- Oxigraph full-text search: the web search returned no relevant Oxigraph results — [search](https://pdf.oxide.fyi/docs/extraction/search)

### Inferences
- For "search across the stack", the cheapest path is enabling Fuseki's jena-text (already required by Skosmos' JenaText dialect) and QLever's text index, then exposing them through existing UIs; a dedicated Elasticsearch/OpenSearch container would require custom indexing code (DBpedia Lookup is the only generic, Dockerised, SPARQL-config-driven indexer found).
- sparql-llm is the only self-hostable "ask the graph" UI with a Docker Compose; it is a Python/Qdrant stack that needs an external or local OpenAI-compatible LLM and per-endpoint VoID descriptions, so it is a heavy but genuinely 2025-2026 addition.
- OLS4 is useful if the stack wants an ontology search/lookup portal (plus MCP), but it does not read from the stack's SPARQL stores.

### Gaps
- Whether Oxigraph has any full-text extension as of 2026 was not confirmed.
- No OSS, maintained "RDF -> OpenSearch -> search UI" product was found; absence is a finding, not proof.
- jekyll-rdf activity after 2023 and any Zazuko static-site generator were not confirmed.

## Key question 4: Vocabulary / thesaurus / SKOS management and DCAT catalogues

### Takeaway
Skosmos 3.x (Dec 2025 - Aug 2026 releases, official Quay images, works against any SPARQL 1.1 endpoint in "Generic" dialect but needs Fuseki+jena-text for full search) is the obvious SKOS browser; iQvoc (Apache, Rails 8.1, v4.16.0 Sept 2026, official compose with Postgres) is the lightweight editor; VocBench 3 (v15.1.2, RDF4J 5.1.6 / GraphDB 11.2.1) is the heavyweight collaborative editor with no ready-made image; SkoHub Vocabs, TemaTres and Opentheso are maintained but are not SPARQL-backed. For DCAT, ckanext-dcat and piveau exist but neither is a thin SPARQL-backed UI; Prez (BSD, ghcr image, v4.25.1 Oct 2026) is the best SPARQL-backed vocabulary/catalogue API.

### Cited Findings

Skosmos (National Library of Finland)
- "Thesaurus and controlled vocabulary browser using SKOS and SPARQL"; 268 stars; last push 2026-10-05; GitHub licence field NOASSERTION — [GitHub metadata](https://github.com/NatLibFi/Skosmos)
- Releases: Skosmos 3.4 2026-08-31; 3.3 2026-06-09; 3.2 2026-03-31; 3.1 2026-02-06; 3.0 2025-12-10 — [releases.atom](https://github.com/NatLibFi/Skosmos/releases.atom)
- 3.0: front-end rewrite, plugin framework overhaul, PHP 8.1-8.4, EasyRdf 1.18, Docker install docs updated; 3.1: more settings via environment variables "which eases Docker deployment"; 3.2: Docker image build reimplemented (slimmer images), BCP47 collation; 3.3/3.4: accessibility work — [releases page](https://github.com/NatLibFi/Skosmos/releases)
- Pre-built images `quay.io/natlibfi/skosmos:[tag]` from 3.0 on; `latest` tracks newest release; example `-p 8080:80` — [Skosmos wiki: Install with Fuseki in Docker](https://github-wiki-see.page/m/NatLibFi/Skosmos/wiki/Install-Skosmos-with-Fuseki-in-Docker)
- dockerfiles README: compose runs `fuseki` (2 GB), `fuseki-cache` (Varnish, 1-week gzip cache) and `skosmos-web` using `config/config-docker-compose.ttl`; host ports Skosmos 9090, Fuseki 3030 (data-loading section says 9030), cache 9031, overridable via `SKOSMOS_PORT`, `FUSEKI_PORT`, `CACHE_PORT`; images ~530 MB + 140 MB + 260 MB; "the Fuseki backend must support the JenaText dialect"; can point at "any other existing Apache Jena server, preferably with the Jena Text extension" — [dockerfiles/README.md](https://raw.githubusercontent.com/NatLibFi/Skosmos/main/dockerfiles/README.md)
- Configuration: `skosmos:sparqlEndpoint` (falls back to env `SKOSMOS_SPARQL_ENDPOINT`, default `http://localhost:3030/ds/sparql`); `skosmos:sparqlDialect` defaults to `Generic` ("plain SPARQL 1.1"), `JenaText` for Fuseki with the Jena text index; per-vocabulary `void:sparqlEndpoint`, `skosmos:sparqlGraph` and dialect overrides; features depending on Jena text (e.g. `searchByNotation`) are unavailable in Generic mode — [Skosmos wiki: Configuration](https://github.com/NatLibFi/Skosmos/wiki/Configuration)
- A 2026-10-09 comparison blog pins Fuseki 6.2.0 in the Skosmos compose and summarises "Skosmos to publish, iQvoc to curate, VocBench to collaborate at scale" — [pistack.xyz](https://www.pistack.xyz/posts/2026-10-09-self-hosted-skos-vocabulary-management-skosmos-iqvoc-vocbench/)

iQvoc (innoQ)
- "A SKOS(-XL) Vocabulary Management System for the Semantic Web"; 124 stars; last push 2026-10-07 — [GitHub metadata](https://github.com/innoq/iqvoc)
- Releases: v4.16.0 2026-09-10; v.4.15.1 and v4.15.0 2026-09-04; v4.14.5 2024-02-02 — [releases.atom](https://github.com/innoq/iqvoc/releases.atom); v4.15.0 "Upgraded to Rails 8.1 and dropped Ruby versions 3.2 and older" — [releases page](https://github.com/innoq/iqvoc/releases)
- README: Apache License 2.0; `docker-compose up` with PostgreSQL; default credentials in `db/seeds.rb`; API docs at `APP_URI/apidoc`; no SPARQL endpoint is mentioned — [README](https://github.com/innoq/iqvoc)
- Compose exposes 3000:3000 and uses `postgres:14`; defaults are "demo-grade"; data lives in PostgreSQL (backups are `pg_dump`, not RDF dumps) — [pistack.xyz](https://www.pistack.xyz/posts/2026-10-09-self-hosted-skos-vocabulary-management-skosmos-iqvoc-vocbench/)

VocBench 3 (University of Rome Tor Vergata / Semantic Turkey)
- Source on Bitbucket; the sys-admin manual references VocBench 15.1.2 with RDF4J 5.1.6; GraphDB recommendations: VB3 15.x -> GraphDB 10.x/11.x, recommended 11.2.1 (avoid 11.4.1); VB3 12-14.x -> >= 10.6.2; lucene-fts plugin "built for Java 17"; Semantic Turkey port 1979 — [VocBench sys manual](https://vocbench.uniroma2.it/doc/sys/)
- Admin manual recommends a separate triple store; Java 17+ — [search summary of vocbench.uniroma2.it/doc/sys](https://vocbench.uniroma2.it/doc/sys)
- VocBench v8.0 (2020) "introduced a docker distribution of VB3" — [W3C semantic-web list](https://lists.w3.org/Archives/Public/semantic-web/2020Jul/0238.html)
- "No ready-made Docker image; self-assembled, typically against an existing triple store" — [pistack.xyz](https://www.pistack.xyz/posts/2026-10-09-self-hosted-skos-vocabulary-management-skosmos-iqvoc-vocbench/)
- Example deployment: Internet of Water Glossary runs "a docker image of VocBench v.3.6.0.0 with GraphDB Free" — [GitHub internetofwater/Glossary](https://github.com/internetofwater/Glossary)

SkoHub Vocabs
- "A lightweight tool to publish SKOS Vocabularies"; Apache-2.0; 46 stars; last push 2026-07-02 — [GitHub metadata](https://github.com/skohub-io/skohub-vocabs)
- Static site generator producing SKOS file, lookup API and HTML; image `skohub/skohub-vocabs-docker:latest` (mount `public/`, `data/`, `.env`, optional `config.yaml`); `docker compose up` dev server on port 8000; input is Turtle in `./data`; Node 22+; no SPARQL endpoint involved; git triggering via the separate SkoHub Webhook — [README](https://github.com/skohub-io/skohub-vocabs)
- No GitHub releases exist ("There aren't any releases here") — [releases page](https://github.com/skohub-io/skohub-vocabs/releases)
- SkoHub Pages publishes via GitHub Pages "without requiring an additional server"; 2025 HMC workshop — [events.hifis.net](https://events.hifis.net/event/2553)
- skohub-editor is archived (last push 2025-10-30) — [GitHub metadata](https://github.com/skohub-io/skohub-editor)

TemaTres
- "Web application for management formal representations of knowledge, like controlled vocabularies, taxonomies, thesauri"; 143 stars; last push 2026-10-01; GitHub licence field empty — [GitHub metadata](https://github.com/tematres/TemaTres-Vocabulary-Server)
- Releases: 3.6.1 2026-04-30 (vocabulary status levels, HTML export, Adodb5/HTMLPurifier updates); 3.6 2025-08-04 (Wikidata as source); 3.5.2 2025-02-21 — [releases.atom](https://github.com/tematres/TemaTres-Vocabulary-Server/releases.atom); [3.6.1 notes](https://github.com/tematres/TemaTres-Vocabulary-Server/releases/tag/v3.6.1)
- Release notes do not mention Docker or SPARQL — [releases page](https://github.com/tematres/TemaTres-Vocabulary-Server/releases)

Opentheso
- MOM-CNRS/Opentheso: multilingual ISO 25964 thesaurus manager; CeCILL-C licence; imports/exports SKOS, Turtle, JSON-LD, CSV (+PDF export); REST (OpenAPI) and GraphQL web services; Ark/Handle identifiers; 34 stars; last push 2026-10-12; no GitHub releases; SPARQL not mentioned — [README](https://github.com/MOM-CNRS/Opentheso); [GitHub metadata](https://github.com/MOM-CNRS/Opentheso)
- Docker: upstream compose references `miledrousset/opentheso2:latest` (Tomcat 9.0) and `miledrousset/opentheso2-postgres:latest` — [ecosystem.code.gouv.fr](https://ecosystem.code.gouv.fr/usage/docker/miledrousset%2Fopentheso2); third-party `viaacode/opentheso2-docker` (MIT, last push 2023-09-20) — [GitHub metadata](https://github.com/viaacode/opentheso2-docker)

Other vocabulary/ontology tools
- WebProtégé: 806 stars; last push 2026-07-28; licence NOASSERTION — [GitHub metadata](https://github.com/protegeproject/webprotege)
- OrionBelt Ontology Builder: "Browser-based ontology workbench for OWL ontologies and SKOS vocabularies. Streamlit + rdflib, no Java"; Business Source License 1.1 converting to Apache-2.0 on 2030-03-30; Docker Hub image, port 8501; read-only SPARQL console over the loaded ontology only (no remote endpoint connection documented); 216 stars; last push 2026-10-14; copyright from 2025 — [README](https://github.com/ralforion/orionbelt-ontology-builder)
- Widoco (ontology documentation): Apache-2.0; 401 stars; last push 2026-10-13 — [GitHub metadata](https://github.com/dgarijo/Widoco); pyLODE: BSD-3-Clause; 231 stars; last push 2026-09-19 — [GitHub metadata](https://github.com/RDFLib/pyLODE)
- VocPrez is archived (last push 2024-08-20; GPL-3.0) — [GitHub metadata](https://github.com/RDFLib/VocPrez)
- Prez (RDFLib / Kurrawong): "data-configurable Linked Data API framework that delivers profiles of Knowledge Graph data according to the Content Negotiation by Profile standard"; BSD-3-Clause; 40 stars; last push 2026-10-06 — [GitHub metadata](https://github.com/RDFLib/prez); releases v4.25.1 2026-10-01, v4.25.0 2026-09-23, v4.24.0 2026-09-21 (Jena Lucene-backed CQL search), v4.23.6 2026-01-12 — [releases page](https://github.com/RDFLib/prez/releases); image `ghcr.io/rdflib/prez` (tags `latest`, `3`, `3.2`, `3.2.4`…), port 8000, env `SPARQL_ENDPOINT` ("usually the only variable you need to set"), `SPARQL_REPO_TYPE` (`remote` | `pyoxigraph` | `oxrdflib`), `SPARQL_USERNAME/PASSWORD`, `ENABLE_SPARQL_ENDPOINT` (default False), `SPARQL_TIMEOUT` 30; data-only API, HTML via separate `RDFLib/prez-ui`; demo compose runs Prez + Prez UI + Fuseki; "active development has moved to kurrawong/prez" — [README](https://github.com/RDFLib/prez)
- UKGovLD registry-core (linked data registry, self-contained WAR): Apache-2.0; 24 stars; last push 2026-10-06; version 2.3.20 — [README](https://github.com/UKGovLD/registry-core)

DCAT catalogues
- ckanext-dcat ("CKAN ♥ DCAT"): 194 stars; last push 2026-08-11 — [GitHub metadata](https://github.com/ckan/ckanext-dcat)
- piveau: open-source DCAT/DCAT-AP metadata catalogue with microservice architecture (Fraunhofer FOKUS); the Interoperable Europe page is marked archived; a maintainer suggests SPARQL to retrieve full catalogue metadata — [Interoperable Europe](https://interoperable-europe.ec.europa.eu/collection/open-data/solution/piveau/introduction); [opencode.de forum](https://discourse.opencode.de/t/wie-vollstaendigen-dcat-katalog-abrufen/2799); GitLab group landing page only links to piveau.eu and doc.piveau.eu — [gitlab.com/piveau](https://gitlab.com/piveau)
- PoolParty is commercial (not OSS) — not evaluated.

### Inferences
- Skosmos 3.x is the single best vocabulary addition: official multi-arch-ish images, env-var configuration since 3.1, and the `Generic` dialect means it can be pointed at the stack's QLever/Oxigraph endpoint for browsing, while hooking it to the existing Fuseki (with jena-text enabled) unlocks full search. Expect ~1 GB of images if the bundled Fuseki+Varnish are used; the stack can instead reuse its own Fuseki.
- iQvoc is the lightest editor to add (two containers) but it keeps data in PostgreSQL; to feed Skosmos/QLever the SKOS export would have to be loaded into a store periodically.
- VocBench 3 is not a quick compose addition: it needs Semantic Turkey (Java 17), a separate RDF4J 5.1.6 server or GraphDB 11.2.1, and manual packaging.
- Prez is the best SPARQL-backed API/UI pair for publishing SKOS/DCAT/spatial data from the stack's own stores; `SPARQL_REPO_TYPE=remote` with `SPARQL_ENDPOINT` set to Fuseki/QLever is enough, and `prez-ui` provides the HTML.
- TemaTres and Opentheso are mature editors but do not integrate with SPARQL stores; they only matter if SKOS authoring in a PHP/Java app is wanted.

### Gaps
- Skosmos licence: GitHub shows NOASSERTION; the project's licence text was not read in this session (confirm before packaging).
- VocBench exact release date for 15.1.2 and its current Docker artefacts (Bitbucket downloads page returned no content).
- Whether Prez has been tested against QLever/Oxigraph remote endpoints (README lists Fuseki in the demo; GraphDB not mentioned).
- piveau Docker images, licence and 2025-2026 activity not retrieved (GitLab landing page only).

## Key question 5: Notebook / IDE integrations

### Takeaway
The Jupyter `sparql-kernel` is effectively frozen (last push Oct 2022, PyPI 1.0.5 from 2017), so a JupyterLab service should rely on rdflib/SPARQLWrapper/kglab in a standard Python kernel; the actively maintained editor-side tooling in 2026 is Zazuko's VS Code SPARQL Notebook (`.sparqlbook`, endpoint per cell, 1.0.14, last commit March 2026) and the QLever team's Qlue-ls SPARQL language server (Rust/LSP/WASM, pushed Oct 2026). Apache Zeppelin has a built-in Jena-based `%sparql` interpreter.

### Cited Findings
- paulovn/sparql-kernel: "A Jupyter kernel to launch queries against SPARQL endpoints"; BSD-3-Clause; 102 stars; last push 2022-10-28 — [GitHub metadata](https://github.com/paulovn/sparql-kernel); PyPI `sparqlkernel` wrapper kernel built on SPARQLWrapper and rdflib, latest listed release 1.0.5 (2017), install via `pip install sparqlkernel` + `jupyter sparqlkernel install` — [PyPI](https://pypi.python.org/pypi/sparqlkernel); a prebuilt image `asanchez75/datascience-notebook:sparqlkernel` was updated ~8 years ago — [Docker Hub](https://hub.docker.com/r/asanchez75/datascience-notebook)
- kglab (Derwen): Python graph-data-science abstraction atop rdflib, pySHACL, NetworkX etc.; MIT; 695 stars; last push 2026-01-25 — [GitHub metadata](https://github.com/DerwenAI/kglab)
- Zazuko VS Code SPARQL Notebook: `.sparqlbook` files; SELECT/ASK/CONSTRUCT/DESCRIBE cells; `[endpoint=...]` comment to set an endpoint per cell, else notebook-wide; local RDF files as stores ("Use File as Store", glob patterns); table rendering via `application/sparql-results+json`; export to Markdown; 37 stars; last push 2026-03-06 — [README](https://github.com/zazuko/vscode-sparql-notebook); [GitHub metadata](https://github.com/zazuko/vscode-sparql-notebook); Marketplace version 1.0.14, 7,612 installs — [VS Marketplace](https://marketplace.visualstudio.com/items?itemName=Zazuko.sparql-notebook); March 2026 commits add "Save cell to File"/"Link Query File" and SPARQL Anything use-case docs — [commits feed](https://github.com/zazuko/vscode-sparql-notebook/commits/main.atom)
- Zazuko `vscode-sparql-snippets` recommends pairing with the Stardog RDF Grammars and SPARQL Language Server; RDFox also ships a VS Code extension; a "Linked Data Extension" for VS Code offers conversion/visualisation/querying — [GitHub](https://github.com/zazuko/vscode-sparql-snippets); [RDFox blog](https://oxfordsemantic.tech/blog/the-rdfox-vs-code-extension-auto-complete-syntax-highlighting-and-custom-icons); [Solid forum](https://forum.solidproject.org/t/linked-data-extension-for-vscode/5628)
- Qlue-ls (qlever-dev): "A SPARQL language server" in Rust, built for the web (WASM); MIT; 49 stars; last push 2026-10-13; completion, formatting, hover, diagnostics, code actions; backend-powered subject/predicate/object suggestions require per-KG completion queries; config `qlue-ls.toml`/`.yml`; browser demo at qlue-ls.com; packages on crates.io, npm, PyPI — [README](https://github.com/qlever-dev/qlue-ls); [GitHub metadata](https://github.com/qlever-dev/qlue-ls)
- Apache Zeppelin SPARQL interpreter: `%sparql` paragraphs; "only supports Apache Jena to query SPARQL-Endpoints"; properties `sparql.endpoint` (default DBpedia), `sparql.engine=jena`, `sparql.replaceURIs`, `sparql.removeDatatypes`; artifact `zeppelin-sparql` — [Zeppelin 0.9.0 docs](https://zeppelin.apache.org/docs/0.9.0/interpreter/sparql.html)
- Streamlit: a Streamlit blog tutorial queries a SPARQL endpoint with SPARQLWrapper and renders nodes/edges with the Agraph component; no off-the-shelf SPARQL dashboard app was found — [Streamlit blog](https://blog.streamlit.io/the-streamlit-agraph-component)
- Gastrodon (Jupyter + RDF/SPARQL analysis) is listed in awesome-semantic-web — [awesome-semantic-web](https://raw.githubusercontent.com/semantalytics/awesome-semantic-web/master/README.md)
- A 2025-era project pairs Jupyter `%%sparql` cell magics with a local Blazegraph in Docker (Python 3.9-3.11) — [tangled.org mirror](https://next.tangled.org/okikio.dev/sparql-client/tree/dev/infra/blazegraph)

### Inferences
- A `jupyter` service built from `jupyter/minimal-notebook` (or `quay.io/jupyter/...`) with `pip install rdflib SPARQLWrapper kglab` is the robust option; `sparqlkernel` can be added but will not be maintained upstream.
- VS Code integrations are not Docker services but are worth documenting in the stack README: SPARQL Notebook (endpoint-per-cell against the stack's ports) and Qlue-ls (its WASM build could even be embedded in a stack-hosted editor page).
- Zeppelin is heavy (Spark-oriented) and its SPARQL interpreter only supports Jena; it is not a good fit unless Zeppelin is wanted for other reasons.

### Gaps
- Exact Qlue-ls release version/date (crates.io and PyPI pages did not render).
- No "rdfnotebook" project was located.
- No Observable-style SPARQL notebook service was found.

## Key question 6: SPARQL endpoint management, proxies, monitoring, dashboards and API generators

### Takeaway
dbcls/sparql-proxy (MIT, ghcr image, Sept 2026) gives caching, job control and an admin UI in front of any endpoint; grlc (MIT, v1.3.11 May 2026, `clariah/grlc` image) remains the standard "SPARQL queries to OpenAPI" generator; Prez and Elda cover Linked Data API profiles; the Flanders Make Grafana SPARQL datasource (1.1.0, Oct 2025, Comunica-based) plus the new sparql-prometheus-exporter (Apache, Go, July 2026) and QLever's `/metrics` make SPARQL-driven Grafana dashboards feasible. QLever UI can be run standalone but is documented only for QLever backends.

### Cited Findings
- QLever UI: "A user-friendly interface for the QLever SPARQL engine"; Apache-2.0; 53 stars; last push 2026-04-26 (commits: "Allow Python versions starting from 3.10", "Switch to https://qlever.dev in default qleverui.sqlite3"); Dockerfile and `docs/install_qleverui.md` — [README](https://github.com/ad-freiburg/qlever-ui); [commits feed](https://github.com/ad-freiburg/qlever-ui/commits/master.atom); backends are added in `/admin` (Django superuser) or imported from example settings; autocompletion uses QLever-specific warmup/context queries in a template language (suggestion modes 2/3); optional "Map view base URL" for a self-hosted Petrimaps; the doc does not say whether non-QLever endpoints are supported — [configure_qleverui.md](https://raw.githubusercontent.com/ad-freiburg/qlever-ui/master/docs/configure_qleverui.md)
- QLever UI2 (student project): QLever URL configured in `docker-compose.yml`, served on port 8080 — [UI2 install docs](https://ad-publications.cs.uni-freiburg.de/student-projects/qlever-ui-2/getting-started/installation.html)
- dbcls/sparql-proxy: "provides cache, job control, and logging for any SPARQL endpoint"; MIT; 38 stars; last push 2026-09-01 — [GitHub metadata](https://github.com/dbcls/sparql-proxy); features: validates queries and omits SPARQL Update, job queue with management UI, `/admin` dashboard, optional cache (file/memory/Redis/memcached, snappy), query logging, experimental OFFSET/LIMIT splitting and plugins; image `ghcr.io/dbcls/sparql-proxy`, e.g. `docker run -p 8080:3000 -e SPARQL_BACKEND=http://example.com/sparql ghcr.io/dbcls/sparql-proxy`; env `SPARQL_BACKEND` (required), `PORT` (3000), `ADMIN_USER`/`ADMIN_PASSWORD` (defaults admin/password), `CACHE_STORE`, `MAX_CONCURRENCY`, `JOB_TIMEOUT`, `MAX_LIMIT`, `ROOT_PATH`, `QUERY_LOG_PATH`; only tag in feed is `20160318` — [README](https://github.com/dbcls/sparql-proxy); [tags feed](https://github.com/dbcls/sparql-proxy/tags.atom)
- SPARQLES (endpoint availability/discoverability/performance/interoperability monitor): BSD-2-Clause; 28 stars; last push 2022-10-20 — [GitHub metadata](https://github.com/pyvandenbussche/sparqles); OpenLink maintains a fork — [OpenLinkSoftware/sparqles](https://github.com/OpenLinkSoftware/sparqles); SWJ paper — [SWJ](https://www.semantic-web-journal.net/node/1381)
- QLever monitoring: Prometheus metrics at `/metrics` on the main port, disabled by default, enabled with `--enable-metrics`, access-token protected; `/ping` for health; Grafana dashboard template 25577 "QLever metrics"; dataset-level metrics via sparql-prometheus-exporter — [docs.qlever.dev/monitoring](https://docs.qlever.dev/monitoring/)
- sparql-prometheus-exporter (Qup42): "runs configured SPARQL queries against an endpoint and exposes the results as metrics — triple counts, instances per class, data freshness"; Go; Apache-2.0; created 2026-07-16, last push 2026-08-13; blackbox-style multi-target (`?target=<endpoint>`); build with `docker build`, run on port 9199 with `config.yml` mounted at `/etc/sparql-exporter/config.yml`; YAML `modules` -> `queries` with `query`, `metric_name`, `value`, `labels`, `value_type` — [README](https://github.com/Qup42/sparql-prometheus-exporter); [GitHub metadata](https://github.com/Qup42/sparql-prometheus-exporter)
- Grafana `flandersmake-sparql-datasource`: "adds support for SPARQL endpoints to Grafana. Under the hood, it uses the Comunica framework"; version 1.1.0 (released 2025-10-20, adds variable interpolation), first release 1.0.0 June 2024; requires Grafana >= 10.0.3; configured with endpoint URL and optional basic auth; install via `grafana-cli plugins install flandersmake-sparql-datasource` — [Grafana plugin page](https://grafana.com/grafana/plugins/flandersmake-sparql-datasource/); [changelog](https://grafana.com/grafana/plugins/flandersmake-sparql-datasource/changelog/); source repo MIT, last push 2025-10-20, README is still the plugin template — [GitHub](https://github.com/Flanders-Make-vzw/grafana-sparql-datasource)
- grlc: "grlc builds Web APIs using shared SPARQL queries"; MIT; 151 stars; last push 2026-10-01 — [GitHub metadata](https://github.com/CLARIAH/grlc); releases v1.3.11 2026-05-13, v1.3.10 2025-04-02, v1.3.9 2024-02-28 — [releases page](https://github.com/CLARIAH/grlc/releases); Docker image `clariah/grlc`, `docker run -p 8088:80 ... clariah/grlc`, env `GRLC_SPARQL_ENDPOINT`, `GRLC_GITHUB_ACCESS_TOKEN`; endpoint can also be set per query (`#+ endpoint:` decorator) or per request; one API operation per `.rq` file; Swagger at `<api>/swagger` — [PyPI grlc 1.3.2](https://pypi.org/project/grlc/1.3.2); [Docker Hub clariah/grlc](https://hub.docker.com/r/clariah/grlc)
- rdflib-endpoint: "Deploy SPARQL endpoints from RDFLib Graphs"; MIT; 99 stars; last push 2026-07-23 (serves endpoints rather than consuming them) — [GitHub metadata](https://github.com/vemonet/rdflib-endpoint)
- SPARQL micro-services (Wimmics): PHP; Apache-2.0; 38 stars; last push 2024-11-04 — [GitHub metadata](https://github.com/frmichel/sparql-micro-service)
- Elda (Epimorphics Linked Data API): 57 stars; last push 2026-10-02; licence NOASSERTION; no GitHub releases ("There aren't any releases here") — [GitHub metadata](https://github.com/epimorphics/elda); [releases page](https://github.com/epimorphics/elda/releases)
- Zazuko kopflos ("Linked Data APIs"): MIT; 16 stars; last push 2026-10-02 — [GitHub metadata](https://github.com/zazuko/kopflos)
- Comunica 5.2 (2026-04-14) added a YASGUI-based HTML view to its SPARQL endpoint and improved SPARQL endpoint detection — [comunica.dev blog](https://comunica.dev/blog/2026-04-14-release_5_2/)
- MCP servers over SPARQL (2026): `comunica/comunica-feature-mcp` ("Comunica packages for exposing query execution through MCP"; MIT; 14 stars; created 2026-02-10, last push 2026-09-24; six servers incl. SPARQL (Web), File, HDT, Solid, Link Traversal) — [README](https://github.com/comunica/comunica-feature-mcp); [GitHub metadata](https://github.com/comunica/comunica-feature-mcp); `dbcls/togomcp` (life-science KGs; MIT; last push 2026-10-14) — [GitHub metadata](https://github.com/dbcls/togomcp); Proto-OKN MCP server (BSD-3) — [glama.ai](https://glama.ai/mcp/servers/@sbl-sdsc/mcp-proto-okn/blob/0cf1b4419b2761a7361d7625d79f3a2de6e4c03a/README.md); sparql-llm MCP at chat.expasy.org/mcp — [README](https://github.com/sib-swiss/sparql-llm)
- GRASP (Freiburg): "Generic Reasoning and SPARQL generation across Knowledge Graphs"; Apache-2.0; 26 stars; last push 2026-10-13; `pip install grasp-rdf`, CLI `grasp run/file/serve`, Docker, Svelte web app, public demo grasp.cs.uni-freiburg.de; `grasp setup` auto-configures a KG by exploring its SPARQL endpoint, default endpoint is QLever; supports OpenAI, Anthropic and any OpenAI-compatible endpoint (vLLM/Ollama/SGLang); paper at ISWC 2025, won WikiKGQA 2026 at ISWC 2026 — [README](https://github.com/ad-freiburg/grasp)

### Inferences
- `sparql-proxy` is a cheap, generic addition (one container, `SPARQL_BACKEND` env) that also protects QLever/Fuseki from SPARQL Update via browser UIs and gives a job dashboard; its lack of recent tags means pinning by image digest.
- A Grafana + Prometheus pair with the Flanders Make datasource and sparql-prometheus-exporter would give "data-quality dashboards" over any of the stack's stores; QLever additionally exposes engine metrics. The exporter has no published image yet (build from source).
- grlc fits the stack as an "API from a folder of .rq files" service; mount a local query directory rather than relying on GitHub tokens.
- GRASP and sparql-llm are the two credible self-hostable NL-to-SPARQL front-ends from 2025-2026; both need LLM access and per-KG indexing.

### Gaps
- Whether QLever UI works unchanged against Fuseki/Oxigraph (its autocompletion queries are QLever-templated) is undocumented.
- Elda Docker packaging and licence (GitHub NOASSERTION) unverified.
- BASIL (Open University) could not be located via search in this session.
- Grafana plugin signing status not stated on the plugin page.

## Key question 7: What is new or notable in 2025-2026

### Takeaway
The clearest 2025-2026 trends are (a) a wave of MCP/LLM front-ends for SPARQL endpoints (Comunica MCP demo at ESWC 2026, OLS4 MCP, sparql-llm, GRASP at ISWC 2025, AtomGraph Web-Algebra, togomcp), (b) steady major releases of the established UIs (Sparnatural 12/13, Skosmos 3.0-3.4, LinkedDataHub 6, iQvoc 4.15/4.16, Prez 4.2x, Reactodia 0.34/0.35), and (c) new BI/observability bridges (Metabase SPARQL driver, Grafana SPARQL datasource 1.1.0, sparql-prometheus-exporter).

### Cited Findings
- ESWC 2026 (Dubrovnik, 10-14 May 2026) accepted posters/demos include "Comunica MCP SPARQL: Improving the Accuracy of AI Agents using SPARQL-based Access to Decentralized Knowledge Graphs" (Taelman, De Smet), "rudof-MCP: A Model Context Protocol Server for Semantic Web Operations" (Labra Gayo et al.), "VENUS: A Declarative Visualization Library for Knowledge Graph Exploration" (Menin, Michel, Faron), "Solid Cockpit", "bikiDATA: A Python Library to Query and Explore Large-Scale RDF Datasets", "OWLGrEd: Web-Based Visual Ontology Management" — [ESWC 2026 poster/demo list](https://2026.eswc-conferences.org/program/accepted-papers/poster-demo)
- SEMANTiCS 2025 (Vienna, Sept 2025) demo: Nobel Prize Sampo on an external SPARQL endpoint with Sampo-UI — [CEUR Vol-4064](https://ceur-ws.org/Vol-4064/PD-paper17.pdf)
- ISWC 2025: GRASP paper + demo; code released 2025-07-10; WikiKGQA 2026 win announced 2026-08-21 — [GRASP README](https://github.com/ad-freiburg/grasp)
- 2025 arXiv: OnSET "Ontology and Semantic Exploration Toolkit" (2504.08373) — [arXiv](https://arxiv.org/pdf/2504.08373)
- Comunica 5.2 (2026-04-14): YASGUI HTML view on its endpoint — [comunica.dev](https://comunica.dev/blog/2026-04-14-release_5_2/)
- OLS 4.0.1 (2026-10-06) "Add MCP server", embeddings via vector stores — [OLS4 releases](https://github.com/EBISPOT/ols4/releases)
- Skosmos 3.0 2025-12-10 through 3.4 2026-08-31 — [releases.atom](https://github.com/NatLibFi/Skosmos/releases.atom)
- Sparnatural 12.0.0 (2025-09-23, new query JSON format) to 13.1.0 (2026-09-24) — [releases.atom](https://github.com/sparna-git/Sparnatural/releases.atom)
- LinkedDataHub 6.0.0 2026-09-29, 6.1.0 2026-10-04 — [releases.atom](https://github.com/AtomGraph/LinkedDataHub/releases.atom)
- iQvoc v4.15.0 (Rails 8.1) 2026-09-04, v4.16.0 2026-09-10 — [releases.atom](https://github.com/innoq/iqvoc/releases.atom)
- Prez v4.24.0 (Jena Lucene-backed CQL search) 2026-09-21, v4.25.1 2026-10-01 — [Prez releases](https://github.com/RDFLib/prez/releases)
- Reactodia v0.34.0 (2026-03-25, configurable `SparqlDataProvider.lookup()`) to v0.35.2 (2026-08-08) — [Reactodia releases](https://github.com/reactodia/reactodia-workspace/releases)
- Rhizomer API added a QLever server type on 2025-08-05 — [commits feed](https://github.com/rhizomik/rhizomerAPI/commits/master.atom)
- Metabase SPARQL driver 0.0.16-0.0.18 released 2026-10-01 to 2026-10-06 — [releases.atom](https://github.com/jhisse/metabase-sparql-driver/releases.atom)
- Grafana SPARQL datasource 1.1.0 released 2025-10-20 — [Grafana changelog](https://grafana.com/grafana/plugins/flandersmake-sparql-datasource/changelog/)
- sparql-prometheus-exporter created 2026-07-16 — [GitHub metadata](https://github.com/Qup42/sparql-prometheus-exporter)
- Qlue-ls SPARQL language server (created 2024-08-21, pushed 2026-10-13) — [GitHub metadata](https://github.com/qlever-dev/qlue-ls)
- LD-Explorer (GCHQ) actively updated through 2026-10-12 — [commits feed](https://github.com/gchq/LD-Explorer/commits/main.atom)
- Practitioner comparison blog "Self-hosted SKOS vocabulary management: Skosmos, iQvoc, VocBench" dated 2026-10-09 — [pistack.xyz](https://www.pistack.xyz/posts/2026-10-09-self-hosted-skos-vocabulary-management-skosmos-iqvoc-vocbench/)
- Zazuko's "new SPARQL notebook release: run cells on different endpoints" was announced on the KGC community (2022), and the extension was still receiving features in March 2026 — [KGC community](https://community.knowledgegraph.tech/x/share/mwcp35b26c9z/new-sparql-notebook-release-run-cells-on-different); [commits feed](https://github.com/zazuko/vscode-sparql-notebook/commits/main.atom)

### Inferences
- Stack-fit shortlist (candidates that are OSS, Dockerisable and store-agnostic, ordered by ease/value): (1) Skosmos 3.4 (`quay.io/natlibfi/skosmos`, `SKOSMOS_SPARQL_ENDPOINT`, dialect Generic or JenaText), (2) Sparnatural 13.1 (static bundle + SHACL config; needs CORS or proxy), (3) Sparklis (`sferre/sparklis`, port 8080, `?endpoint=` param), (4) dbcls/sparql-proxy (`ghcr.io/dbcls/sparql-proxy`, `SPARQL_BACKEND`), (5) grlc (`clariah/grlc`, 8088, `GRLC_SPARQL_ENDPOINT`), (6) Prez + prez-ui (`ghcr.io/rdflib/prez`, 8000, `SPARQL_ENDPOINT`), (7) Metabase with SPARQL driver (`ghcr.io/jhisse/metabase-sparql-driver`), (8) Grafana + flandersmake-sparql-datasource + sparql-prometheus-exporter, (9) LD-Explorer (build from Dockerfile, nginx 8080), (10) Rhizomer (`rhizomik/rhizomer-api` + `rhizomik/rhizomer-eye`), (11) iQvoc (compose with Postgres, 3000), (12) LodView (`linkeddatacenter/lodview`) or LDView (Codeberg compose), (13) sparql-llm / GRASP for LLM front-ends (need LLM keys), (14) a Jupyter service with rdflib/kglab.
- Prefer to avoid or defer: HyperGraphQL/GraphSPARQL (dormant), LodLive/Tabulator/Gephi plugin (unmaintained), VocBench 3 (no image, heavy), OLS4 (file-based, not SPARQL-backed), Zeppelin (Jena-only interpreter, heavy), OrionBelt (BSL licence, no endpoint connection).
- A practical "everything through one proxy" pattern emerges: route browser-only tools (Sparnatural, Sparklis, LD-Explorer, YASGUI) through sparql-proxy or Trifid to get CORS, caching and update-blocking in one place.

### Gaps
- No LinkedIn or Reddit practitioner posts about 2025-2026 front-end preferences were retrievable; the only practitioner-style source found is the 2026-10-09 pistack.xyz comparison.
- ISWC 2025 demo-track list was not retrieved directly (only GRASP confirmed via its README).
- The ESWC 2026 poster/demo list was truncated after item 13 of 20+, so later entries were not reviewed.
