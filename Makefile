COMPOSE ?= docker compose
# QLever runs as these ids so the index it writes into ./qlever is owned by you (Linux). Override in .env.
export QLEVER_UID ?= $(shell id -u)
export QLEVER_GID ?= $(shell id -g)

.DEFAULT_GOAL := help
.PHONY: help up down restart ps logs qlever-index load smoke oxigraph-up fuseki-up tools validate jupyter-up ontop-up graphdb-up build clean

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage: make <target>\n\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

qlever-index: ## One-time: download the Olympics demo data and build the QLever index
	$(COMPOSE) --profile setup run --rm qlever-index

up: ## Start the default stack (QLever primary)
	$(COMPOSE) up -d
	@echo "Landing page: http://localhost:$${LANDING_PORT:-8080}"

down: ## Stop the stack (keeps data volumes)
	$(COMPOSE) --profile '*' down --remove-orphans

restart: down up ## Restart the stack

ps: ## Show service status
	$(COMPOSE) ps

logs: ## Tail logs (make logs S=fuseki for one service)
	$(COMPOSE) logs -f --tail=100 $(S)

build: ## Build the locally built images (WebVOWL, OpenRefine, SHACL Play, pySHACL, tools, Ontop)
	$(COMPOSE) --profile '*' build

load: ## Load data/sample into Fuseki (and Oxigraph when it is running)
	./scripts/load.sh

smoke: ## Check that every service answers
	./scripts/smoke.sh

oxigraph-up: ## Start the Oxigraph variant instead of QLever
	$(COMPOSE) -f compose.yml -f compose.oxigraph.yml up -d

fuseki-up: ## Start with Fuseki as the primary store (no QLever)
	$(COMPOSE) -f compose.yml -f compose.fuseki.yml up -d

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
