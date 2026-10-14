# data/

Mounted into most containers as `/data`. Drop your own files here.

| Path | What it is |
|---|---|
| `sample/semantic-stack.ttl` | Small demo dataset: the stack describing itself. Loaded into Fuseki (and Oxigraph) by `scripts/load.sh`. |
| `sample/semantic-stack-vocab.ttl` | The vocabulary behind it. Visualise it in WebVOWL, document it with pyLODE, or use it as the Ontop ontology. |
| `sample/shapes.ttl` | SHACL shapes for the sample data. Validate with pySHACL or Fuseki's `/ds/shacl` endpoint. |
| `queries/*.rq` | Example queries: `01`-`03` for the sample data, `10`-`11` for the Olympics data in QLever, `20` for Comunica. |
| `rml/` | A CSV plus YARRRML mapping; see `rml/README.md`. |
| `linkml/semantic-stack.yaml` | The same model as a LinkML schema; generate OWL, SHACL, JSON Schema or Pydantic from it. |
| `out/` | Ignored by git; put generated files here. |

The sample IRIs live under `http://localhost:8084/` so Trifid can dereference them, e.g.
<http://localhost:8084/service/fuseki> when Trifid points at a store that holds the sample data
(`compose.oxigraph.yml` or `compose.fuseki.yml`).
