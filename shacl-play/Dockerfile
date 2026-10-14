# SHACL Play (Sparna): validate data against SHACL, document shapes as HTML/UML, generate shapes
# from data, convert OWL to SHACL, run SHACL rules. Built from source at a pinned release because
# upstream publishes no registry image; this mirrors upstream's own Dockerfile.
#   docker compose build shacl-play      (Maven build, several minutes the first time)
#   docker compose pull  shacl-play      (prebuilt image from ghcr.io instead)
ARG MAVEN_IMAGE=3.9.6-eclipse-temurin-17
ARG TOMCAT_IMAGE=10.1-jdk17
ARG SHACL_PLAY_GIT_URL=https://github.com/sparna-git/shacl-play.git
ARG SHACL_PLAY_GIT_REF=0.12.5

FROM maven:${MAVEN_IMAGE} AS builder
ARG SHACL_PLAY_GIT_URL
ARG SHACL_PLAY_GIT_REF
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*
WORKDIR /build
RUN git clone --depth 1 --branch "${SHACL_PLAY_GIT_REF}" "${SHACL_PLAY_GIT_URL}" .
RUN mvn -B -q package -DskipTests

FROM tomcat:${TOMCAT_IMAGE}
LABEL org.opencontainers.image.title="semantic-stack shacl-play" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack"
# Graphviz renders the UML diagrams in the generated documentation.
RUN apt-get update && apt-get install -y --no-install-recommends graphviz && rm -rf /var/lib/apt/lists/*
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /build/shacl-play/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
