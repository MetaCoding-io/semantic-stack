# pySHACL as an HTTP validation service (OpenAPI 3). The upstream Docker Hub image lags the PyPI
# release by many versions, so this installs the pinned release with the `http` extra instead.
#   POST http://localhost:8099/validate   {"data_graph": "...turtle...", "shapes_graph": "...turtle..."}
#   Swagger UI at /docs/swagger, OpenAPI schema at /docs/openapi.json
FROM python:3.12-slim

LABEL org.opencontainers.image.title="semantic-stack pyshacl server" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack"

ARG PYSHACL_VERSION=0.40.1
RUN pip install --no-cache-dir "pyshacl[http]==${PYSHACL_VERSION}"

ENV PYSHACL_SERVER=TRUE \
    PYSHACL_SERVER_LISTEN=0.0.0.0 \
    PYSHACL_SERVER_PORT=8099
EXPOSE 8099
CMD ["pyshacl", "--server"]
