# semantic-stack

A Docker-based semantic web technology stack for working with RDF data, ontologies, SPARQL querying, and linked data.

## Services

### Triple Stores

| Service | Port | Description |
|---------|------|-------------|
| **Oxigraph** | [localhost:7878](http://localhost:7878) | Modern Rust-based RDF triplestore with built-in YASGUI UI |
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

```bash
# Standard deployment
docker compose up -d

# Local development (requires monorepo_default network)
docker compose -f docker-compose.local.yml up -d
```

## SPARQL Endpoints

| Store | Query Endpoint | Update Endpoint |
|-------|---------------|-----------------|
| Oxigraph | `http://localhost:7878/query` | `http://localhost:7878/update` |
| Fuseki | `http://localhost:3030/ds/sparql` | `http://localhost:3030/ds/update` |
| Comunica (federated) | `http://localhost:8087/sparql` | N/A (read-only) |

## Linking RDF4J Workbench to a Triple Store

1. Open RDF4J Workbench at [localhost:8082](http://localhost:8082)
2. Navigate to **Repositories** > **New Repository**
3. Select **SPARQL Endpoint Proxy** as the type
4. Set the SPARQL endpoint URL to: `http://oxigraph:7878/query`
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

## Optional Services

### QLever (High-Performance Triplestore)

QLever is a high-performance SPARQL engine capable of Wikidata-scale datasets. It requires a data indexing step before serving queries. A commented-out service definition is included in the docker-compose files.

```bash
pip install qlever
qlever setup-config <dataset>
qlever get-data
qlever index
qlever start
```

### SHACL Playground (Shape Validation)

```bash
git clone https://github.com/zazuko/shacl-playground
cd shacl-playground
docker build -t shacl-playground .
docker run -p 8088:80 shacl-playground
```

## TODOs

- Fork https://github.com/VisualDataWeb/WebVOWL/ with proper URL
