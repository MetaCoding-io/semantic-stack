# LinkedPipes ETL pipelines

`pipelines/semantic-stack.jsonld` is the example pipeline for the `lp-etl` profile. It is the four
things the profile is for, over the sample data, in one run:

| Step | Component | What it does |
|---|---|---|
| Download | *HTTP get* ×2 | fetches `data/sample/semantic-stack.ttl` and `shapes.ttl` from the landing page (`http://landing.internal/data/…`, the stack's own copy of `./data`) |
| Parse | *Files to RDF single graph* ×2 | Turtle → RDF graphs |
| Validate | *SHACL validation* | the data against the shapes; the pipeline fails here if the data does not conform |
| Transform | *SPARQL CONSTRUCT* | the transitive closure of `ss:dependsOn` as `ss:transitivelyDependsOn` (what `data/nemo/dependencies.rls` derives with Nemo) |
| Load | *RDF to file* → *Graph store protocol* | PUTs the result into Fuseki as graph `http://localhost:8084/graph/lp-etl` (the loader runs only after the validation passed) |

Run it:

```bash
make lp-etl-up          # LinkedPipes ETL + the default stack
make lp-etl-run         # store the pipeline, execute it, wait; prints the canvas and execution URLs
```

`scripts/lp-etl.sh` stores the file with `POST /api/v1/pipelines`, which keeps the pipeline IRI
(`http://localhost:9080/resources/pipelines/semantic-stack`), so running it again overwrites the stored
copy and the canvas URL stays the same:
<http://localhost:9080/#/pipelines/edit/canvas?pipeline=http%3A%2F%2Flocalhost%3A9080%2Fresources%2Fpipelines%2Fsemantic-stack>.

The loader logs in to Fuseki as `admin` / `admin`; if you changed `FUSEKI_ADMIN_PASSWORD`, edit the
*Load into Fuseki* component (or the `l-graphStoreProtocol#password` value in the file).

Hand-editing the file: it is the JSON-LD LinkedPipes ETL exports, one named graph for the pipeline
(components, connections, a *run after* edge) plus one configuration graph per component. Component
templates are `http://etl.linkedpipes.com/resources/components/<plugin>/0.0.0` and configuration
properties `http://plugins.linkedpipes.com/ontology/<plugin>#<property>`; the plugin directories in
[linkedpipes/etl](https://github.com/linkedpipes/etl/tree/main/plugins) list them. Pipelines you draw
in the UI can be exported from the pipeline list and dropped in here.
