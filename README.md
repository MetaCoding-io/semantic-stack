# semantic-stack

A Docker-based semantic web technology stack for working with RDF data, ontologies, SPARQL querying, and linked data.

## Services

### Triple Stores

| Service | Port | Description |
|---------|------|-------------|
| **QLever** | [localhost:7001](http://localhost:7001) | High-performance SPARQL engine (Wikidata-scale) - **primary** |
| **Apache Jena Fuseki** | [localhost:3030](http://localhost:3030) | Mature SPARQL 1.1 server with TDB2 storage and reasoning |

### Data Transformation

| Service | Port | Description |
|---------|------|-------------|
| **OntoRefine** | [localhost:7333](http://localhost:7333) | RDF data transformation (Ontotext) |
| **OpenRefine** | [localhost:3333](http://localhost:3333) | Data cleanup and transformation |
| **RML Mapper** | CLI only | Convert CSV/JSON/XML to RDF using RML mappings |

### Visualization & Browsing

| Service | Port | Description |
|---------|------|-------------|
| **WebVOWL** | [localhost:8083](http://localhost:8083) | OWL ontology visualization |
| **Trifid** | [localhost:8084](http://localhost:8084) | Linked Data proxy with Graph Explorer (Zazuko) |
| **Blueprint** | [localhost:8085](http://localhost:8085) | Knowledge graph browser (Zazuko) |

### Query Tools

| Service | Port | Description |
|---------|------|-------------|
| **RDF4J Workbench** | [localhost:8082](http://localhost:8082) | Web-based RDF repository management |
| **YASGUI** | [localhost:8086](http://localhost:8086) | Standalone SPARQL query editor with autocomplete |
| **Comunica** | [localhost:8087](http://localhost:8087) | Federated SPARQL query engine across multiple endpoints |

## Quick Start

### Default stack (QLever primary)

QLever requires a one-time indexing step before it can serve queries.

```bash
# 1. Initialize QLever with a dataset (e.g. Olympics - 2M triples, takes seconds)
docker compose run --rm qlever -c "
  cd /data &&
  qlever setup-config olympics &&
  qlever get-data &&
  qlever index
"

# 2. Start the full stack
docker compose up -d
```

To use your own RDF data instead:

```bash
# Copy your .ttl/.nt/.nq files into ./data/, then:
docker compose run --rm qlever -c "
  cd /data &&
  qlever setup-config olympics &&
  cp /import/mydata.ttl . &&
  qlever index
"
docker compose up -d
```

### Oxigraph alternative (no indexing required)

Oxigraph is a lightweight Rust-based triplestore that works out of the box with no setup:

```bash
docker compose -f docker-compose.oxigraph.yml up -d
```

Oxigraph provides a built-in YASGUI UI at [localhost:7878](http://localhost:7878) and accepts SPARQL Update for loading data.

### Local development

```bash
# Requires monorepo_default network
docker compose -f docker-compose.local.yml up -d
```

## SPARQL Endpoints

### Default stack (QLever)

| Store | Query Endpoint | Update Endpoint |
|-------|---------------|-----------------|
| QLever | `http://localhost:7001` | `http://localhost:7001` |
| Fuseki | `http://localhost:3030/ds/sparql` | `http://localhost:3030/ds/update` |
| Comunica (federated) | `http://localhost:8087/sparql` | N/A (read-only) |

### Oxigraph stack

| Store | Query Endpoint | Update Endpoint |
|-------|---------------|-----------------|
| Oxigraph | `http://localhost:7878/query` | `http://localhost:7878/update` |
| Fuseki | `http://localhost:3030/ds/sparql` | `http://localhost:3030/ds/update` |
| Comunica (federated) | `http://localhost:8087/sparql` | N/A (read-only) |

## Linking RDF4J Workbench to a Triple Store

1. Open RDF4J Workbench at [localhost:8082](http://localhost:8082)
2. Navigate to **Repositories** > **New Repository**
3. Select **SPARQL Endpoint Proxy** as the type
4. Set the SPARQL endpoint URL to your store (e.g. `http://qlever:7001` or `http://oxigraph:7878/query`)
5. Save the repository configuration

## Using the RML Mapper

The RML Mapper runs as a one-shot CLI tool to convert structured data to RDF:

```bash
# Place your data and mapping files in ./data/, then:
docker compose run --rm rmlmapper -m /data/mapping.ttl

# With YARRRML (human-friendly mapping syntax):
docker run --rm -v $(pwd)/data:/data rmlio/yarrrml-parser:1.10.0 -i /data/mapping.yarrrml.yml -o /data/mapping.rml.ttl
docker compose run --rm rmlmapper -m /data/mapping.rml.ttl
```

## Optional: SHACL Playground

```bash
git clone https://github.com/zazuko/shacl-playground
cd shacl-playground
docker build -t shacl-playground .
docker run -p 8088:80 shacl-playground
```

A commented-out service definition is included in `docker-compose.yml` for reference.

## TODOs

- Fork https://github.com/VisualDataWeb/WebVOWL/ with proper URL
