# pyLODE as an HTTP service: GET /pylode?url=<ontology URL>&profile=ontpub|vocpub|supermodel
# Same release as tools/requirements.txt. Mirrors the upstream "pylode-server" Dockerfile target:
# https://github.com/RDFLib/pyLODE/blob/3.6.0/Dockerfile
FROM python:3.12-slim

LABEL org.opencontainers.image.title="semantic-stack pylode server" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack"

ARG PYLODE_VERSION=3.6.0
RUN pip install --no-cache-dir "pylode[server]==${PYLODE_VERSION}"

ENV PORT=8000
EXPOSE 8000
CMD ["python", "-m", "pylode.server"]
