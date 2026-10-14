# Python toolbox for the stack: rdflib, pySHACL, OWL-RL, SPARQLWrapper, LinkML, pyLODE, pandas, JupyterLab,
# plus the jelly-cli native binary (Jelly binary RDF streaming).
#   docker compose --profile tools run --rm tools sh -c 'jelly-cli rdf to-jelly sample/semantic-stack.ttl > out/semantic-stack.jelly'
#   docker compose --profile tools run --rm tools pyshacl -s sample/shapes.ttl sample/semantic-stack.ttl
#   docker compose --profile tools run --rm tools gen-owl linkml/semantic-stack.yaml
#   docker compose --profile tools run --rm tools pylode sample/semantic-stack-vocab.ttl -o out/vocab.html
FROM python:3.12-slim

LABEL org.opencontainers.image.title="semantic-stack tools" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack"

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates git jq \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt

# jelly-cli: GraalVM native binary from the pinned GitHub release (Linux x86_64 / arm64).
ARG JELLY_CLI_VERSION=v0.10.0
ARG TARGETARCH
RUN arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$arch" in amd64) asset=x86_64 ;; arm64) asset=arm64 ;; *) echo "jelly-cli: unsupported arch $arch" >&2; exit 1 ;; esac; \
    curl -fsSL "https://github.com/Jelly-RDF/cli/releases/download/${JELLY_CLI_VERSION}/jelly-cli-linux-${asset}.gz" \
      | gzip -d > /usr/local/bin/jelly-cli \
 && chmod +x /usr/local/bin/jelly-cli \
 && jelly-cli --version

WORKDIR /data
CMD ["bash"]
