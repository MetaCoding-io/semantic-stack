# OpenRefine from the official release tarball. OpenRefine publishes no official container image,
# and the community image the stack used before (felixlohmeier/openrefine) stopped at 3.5.0 in 2021.
ARG OPENREFINE_VERSION=3.10.0
FROM eclipse-temurin:21-jre-noble

ARG OPENREFINE_VERSION
LABEL org.opencontainers.image.title="OpenRefine" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack" \
      org.opencontainers.image.version="${OPENREFINE_VERSION}"

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL "https://github.com/OpenRefine/OpenRefine/releases/download/${OPENREFINE_VERSION}/openrefine-linux-${OPENREFINE_VERSION}.tar.gz" \
      | tar -xz -C /opt \
 && mv "/opt/openrefine-${OPENREFINE_VERSION}" /opt/openrefine \
 && useradd --system --create-home --home-dir /data refine \
 && chown -R refine:refine /opt/openrefine /data

USER refine
WORKDIR /opt/openrefine
VOLUME /data
EXPOSE 3333

# -i bind all interfaces, -p port, -d workspace dir, -m JVM heap
CMD ["./refine", "-i", "0.0.0.0", "-p", "3333", "-d", "/data", "-m", "2048M"]
