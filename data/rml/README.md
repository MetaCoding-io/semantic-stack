# RML example

Turn `services.csv` into RDF in two steps:

```bash
# 1. YARRRML (YAML) -> RML (Turtle)
docker compose --profile tools run --rm yarrrml -i /data/rml/mapping.yarrrml.yml -o /data/rml/mapping.rml.ttl

# 2. Execute the mapping
docker compose --profile tools run --rm rmlmapper -m /data/rml/mapping.rml.ttl -o /data/rml/output.ttl -s turtle

# 3. Load the result
./scripts/load.sh data/rml/output.ttl
```

Write RML by hand if you prefer; RMLMapper also executes R2RML against databases
(pass `-dsn`, `-u`, `-p`). Generated files are ignored by git.

The same RML runs on SDM-RDFizer, a second engine that scored 100 % on every module of the new
RML specification in the 2026 Knowledge Graph Construction Workshop challenge:

```bash
docker compose --profile tools run --rm sdm-rdfizer      # reads sdm-rdfizer.ini, writes sdm-output/
```
