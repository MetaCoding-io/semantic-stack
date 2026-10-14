# Python toolbox for the stack: rdflib, pySHACL, OWL-RL, SPARQLWrapper, LinkML, pyLODE, pandas, JupyterLab.
#   docker compose --profile tools run --rm tools pyshacl -s sample/shapes.ttl sample/semantic-stack.ttl
#   docker compose --profile tools run --rm tools gen-owl linkml/semantic-stack.yaml
#   docker compose --profile tools run --rm tools pylode sample/semantic-stack-vocab.ttl -o out/vocab.html
FROM python:3.14-slim

LABEL org.opencontainers.image.title="semantic-stack tools" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack"

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates git jq \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt

WORKDIR /data
CMD ["bash"]
