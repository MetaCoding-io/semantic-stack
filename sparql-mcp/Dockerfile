# Generic SPARQL 1.1 MCP server (Kashif-Rabbani/mcp-server-sparql, MIT): SELECT/ASK/CONSTRUCT/DESCRIBE,
# SPARQL Update, Graph Store Protocol and SHACL validation over any endpoint, served over SSE.
# Upstream publishes no image or tags, so this clones a pinned commit.
FROM python:3.13-slim

LABEL org.opencontainers.image.title="semantic-stack sparql-mcp" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack"

ARG MCP_SERVER_SPARQL_REF=d9c0d5743bac0f95ed3c2985b60456f9ffb865b5
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/* \
 && git clone https://github.com/Kashif-Rabbani/mcp-server-sparql.git /app \
 && cd /app && git checkout --quiet "${MCP_SERVER_SPARQL_REF}" && rm -rf .git \
 && pip install --no-cache-dir -e . \
 && apt-get purge -y git && apt-get autoremove -y

WORKDIR /app
EXPOSE 8000
CMD ["python", "server.py"]
