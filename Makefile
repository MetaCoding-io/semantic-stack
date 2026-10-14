COMPOSE ?= docker compose
# QLever runs as these ids so the index it writes into ./qlever is owned by you (Linux). Override in .env.
export QLEVER_UID ?= $(shell id -u)
export QLEVER_GID ?= $(shell id -g)

.DEFAULT_GOAL := help
.PHONY: help up down restart ps logs load smoke qlever-index qlever-up oxigraph-up graphdb-up tools validate jupyter-up ontop-up build clean

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

build: ## Build the locally built images (WebVOWL, OpenRefine, SHACL Play, pySHACL, tools, Ontop)
	$(COMPOSE) --profile '*' build

load: ## Load data/sample into Fuseki (and Oxigraph when it is running)
	./scripts/load.sh

smoke: ## Check that every service answers (add checks: make smoke S="qlever oxigraph")
	./scripts/smoke.sh $(S)

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

clean: ## Stop everything and delete volumes and the QLever index
	$(COMPOSE) --profile '*' down -v --remove-orphans
	find qlever -mindepth 1 ! -name Qleverfile -exec rm -rf {} +
