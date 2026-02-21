# semantic-stack

A Docker-based semantic web technology stack for working with RDF data, ontologies, SPARQL querying, and linked data.

## Services

| Service | Port | Description |
|---------|------|-------------|
| **Blazegraph** | [localhost:9999](http://localhost:9999) | RDF triple store and SPARQL endpoint |
| **RDF4J Workbench** | [localhost:8082](http://localhost:8082) | Web-based RDF repository management |
| **OntoRefine** | [localhost:7333](http://localhost:7333) | RDF data transformation (Ontotext) |
| **OpenRefine** | [localhost:3333](http://localhost:3333) | Data cleanup and transformation |
| **WebVOWL** | [localhost:8083](http://localhost:8083) | OWL ontology visualization |
| **Trifid** | [localhost:8084](http://localhost:8084) | Linked Data proxy (Zazuko) |
| **Blueprint** | [localhost:8085](http://localhost:8085) | Knowledge graph browser (Zazuko) |
| **Oxigraph** | [localhost:7878](http://localhost:7878) | Modern Rust-based RDF triplestore with YASGUI UI |
| **Apache Jena Fuseki** | [localhost:3030](http://localhost:3030) | Mature SPARQL 1.1 server with TDB2 storage |
| **YASGUI** | [localhost:8086](http://localhost:8086) | Standalone SPARQL query editor |

## Quick Start

```bash
# Standard deployment
docker compose up -d

# Local development (requires monorepo_default network)
docker compose -f docker-compose.local.yml up -d
```

## Linking RDF4J Workbench to Blazegraph

1. Open RDF4J Workbench at [localhost:8082](http://localhost:8082)
2. Navigate to **Repositories** > **New Repository**
3. Select **SPARQL Endpoint Proxy** as the type
4. Set the SPARQL endpoint URL to: `http://blazegraph:8080/bigdata/namespace/kb/sparql`
5. Save the repository configuration

## SHACL Playground (Optional)

To add the Zazuko SHACL Playground for validating SHACL shapes:

```bash
git clone https://github.com/zazuko/shacl-playground
cd shacl-playground
docker build -t shacl-playground .
docker run -p 8087:80 shacl-playground
```

A commented-out service definition is included in `docker-compose.yml` for reference.

## TODOs

- Fork https://github.com/VisualDataWeb/WebVOWL/ with proper URL
