COMPOSE ?= docker compose
# QLever runs as these ids so the index it writes into ./qlever is owned by you (Linux). Override in .env.
export QLEVER_UID ?= $(shell id -u)
export QLEVER_GID ?= $(shell id -g)

.DEFAULT_GOAL := help
.PHONY: help up down restart ps logs load smoke screenshots screenshots-publish qlever-index qlever-up oxigraph-up graphdb-up tools validate jupyter-up ontop-up profile virtuoso-up geosparql-up prez-up grlc-up graph-explorer-up docs-up rpt-up lp-etl-up lp-etl-run validation-up observability-up mcp-up graphrag-up ollama-up solid-up build clean

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make <target>\n\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

up: ## Start the default stack (Fuseki primary)
	$(COMPOSE) up -d
	@echo "Landing page: http://localhost:$${LANDING_PORT:-8080}"

down: ## Stop the stack (keeps data volumes)
	$(COMPOSE) --profile '*' down --remove-orphans

restart: down up ## Restart the stack

ps: ## Show service status
	$(COMPOSE) ps

logs: ## Tail logs (make logs S=fuseki for one service)
	$(COMPOSE) --profile '*' logs -f --tail=100 $(S)

build: ## Build the locally built images (WebVOWL, OpenRefine, SHACL Play, pySHACL, pyLODE, sparql-mcp, graphrag-mcp, tools, Ontop)
	$(COMPOSE) --profile '*' build

load: ## Load data/sample into Fuseki (and Oxigraph when it is running)
	./scripts/load.sh

smoke: ## Check that every service answers (add checks: make smoke S="qlever oxigraph")
	./scripts/smoke.sh $(S)

screenshots: ## Screenshot every UI with headless Chromium into screenshots/out (G="default stores" for profile groups)
	cd screenshots && npm install --no-audit --no-fund && npx playwright install chromium && node take.mjs $(or $(G),default) --timeout $(or $(T),60)
	@echo "Gallery: screenshots/out/index.html"

screenshots-publish: ## Shrink a screenshots run into docs/screenshots, the gallery committed to git (needs uv; SRC=path to a downloaded artifact)
	uv run scripts/publish-screenshots.py $(or $(SRC),screenshots/out) docs/screenshots

qlever-index: ## Download the Olympics demo data and build the QLever index (one-time, or after editing qlever/Qleverfile)
	$(COMPOSE) --profile qlever-index run --rm qlever-index

qlever-up: ## Add QLever + QLever UI (builds the index first if there is none)
	@ls qlever/*.index.* >/dev/null 2>&1 || $(MAKE) qlever-index
	$(COMPOSE) --profile qlever up -d

oxigraph-up: ## Add Oxigraph on http://localhost:7878 (waits until it answers, so `make load` can follow)
	$(COMPOSE) --profile oxigraph up -d
	./scripts/smoke.sh oxigraph

tools: ## Open a shell in the Python tools container (rdflib, pySHACL, LinkML, pyLODE, jelly-cli)
	$(COMPOSE) --profile tools run --rm tools

validate: ## Validate data/sample against its SHACL shapes with pySHACL and rudof
	$(COMPOSE) --profile tools run --rm tools pyshacl -s sample/shapes.ttl sample/semantic-stack.ttl
	$(COMPOSE) --profile tools run --rm rudof shacl-validate --shapes sample/shapes.ttl sample/semantic-stack.ttl

jupyter-up: ## Start JupyterLab on http://localhost:8888
	$(COMPOSE) --profile jupyter up -d jupyter

ontop-up: ## Start Postgres + Ontop virtual knowledge graph demo on http://localhost:8089
	$(COMPOSE) --profile ontop up -d postgres ontop

graphdb-up: ## Start GraphDB on http://localhost:7200
	$(COMPOSE) --profile graphdb up -d graphdb

profile: ## Start any profile: make profile P=prez (see `docker compose config --profiles`)
	$(COMPOSE) --profile $(P) up -d

virtuoso-up: ## Add Virtuoso on http://localhost:8890 (Conductor at /conductor), then `make load`
	$(COMPOSE) --profile virtuoso up -d --wait virtuoso

geosparql-up: ## Add Fuseki + GeoSPARQL on http://localhost:3031, then `make load`
	$(COMPOSE) --profile geosparql up -d --wait fuseki-geosparql

prez-up: ## Add the Prez Linked Data API (:8000) and UI (:8001) over Fuseki
	$(COMPOSE) --profile prez up -d

grlc-up: ## Add grlc on http://localhost:8088/api-local/ (REST API from grlc/queries/*.rq)
	$(COMPOSE) --profile grlc up -d

graph-explorer-up: ## Add AWS Graph Explorer on http://localhost:8095/explorer
	$(COMPOSE) --profile graph-explorer up -d

docs-up: ## Add the pyLODE server on http://localhost:8096
	$(COMPOSE) --profile docs up -d

rpt-up: ## Add RPT (SPARQL/GraphQL server with YASGUI over Fuseki) on http://localhost:8642
	$(COMPOSE) --profile rpt up -d

lp-etl-up: ## Add LinkedPipes ETL on http://localhost:9080 (four containers)
	$(COMPOSE) --profile lp-etl up -d

lp-etl-run: ## Store and run the example pipeline (lp-etl/pipelines/semantic-stack.jsonld), wait for it to finish
	./scripts/lp-etl.sh

validation-up: ## Add the ITB SHACL validator on http://localhost:8097/shacl/stack/upload
	$(COMPOSE) --profile validation up -d

observability-up: ## Add Prometheus (:9091), the SPARQL exporter (:9199) and Grafana (:3000)
	$(COMPOSE) --profile observability up -d

mcp-up: ## Add the MCP servers: sparql-mcp (:8103), rudof-mcp (:8102), open-ontologies (:8101)
	$(COMPOSE) --profile mcp up -d

graphrag-up: ## Add Flexible GraphRAG + Qdrant (needs ANTHROPIC_API_KEY or the ollama profile) on http://localhost:8105
	$(COMPOSE) --profile graphrag up -d

ollama-up: ## Add Ollama on http://localhost:11434 (then: docker compose --profile ollama exec ollama ollama pull qwen3:8b)
	$(COMPOSE) --profile ollama up -d

solid-up: ## Add the Community Solid Server on http://localhost:8100
	$(COMPOSE) --profile solid up -d

clean: ## Stop everything and delete volumes and the QLever index
	$(COMPOSE) --profile '*' down -v --remove-orphans
	find qlever -mindepth 1 ! -name Qleverfile -exec rm -rf {} +
