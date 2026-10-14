# MCP server for the Flexible GraphRAG backend (PyPI flexible-graphrag-mcp, Apache-2.0),
# streamable HTTP at /mcp. Talks to the backend named in FLEXIBLE_GRAPHRAG_URL.
FROM python:3.13-slim

LABEL org.opencontainers.image.title="semantic-stack flexible-graphrag-mcp" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack"

ARG FLEXIBLE_GRAPHRAG_MCP_VERSION=0.8.4
RUN pip install --no-cache-dir "flexible-graphrag-mcp==${FLEXIBLE_GRAPHRAG_MCP_VERSION}"

EXPOSE 3001
CMD ["flexible-graphrag-mcp", "--http", "--host", "0.0.0.0", "--port", "3001"]
