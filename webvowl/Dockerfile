# WebVOWL + OWL2VOWL converter in one Tomcat, built from upstream source.
# The historical download (vowl.visualdataweb.org/downloads/webvowl_1.1.7.war) no longer exists and
# neither project publishes binary releases, so this follows upstream's own docker/Dockerfile
# (WebVOWL commit 28e7dd9, June 2026) but clones both repositories at pinned refs.
#
# Build args let you point at a fork:  --build-arg WEBVOWL_GIT_URL=https://github.com/MetaCoding-io/WebVOWL.git
ARG MAVEN_IMAGE=3.9.16-eclipse-temurin-8-noble
ARG NODE_IMAGE=12-alpine
ARG TOMCAT_VERSION=9.0

ARG WEBVOWL_GIT_URL=https://github.com/VisualDataWeb/WebVOWL.git
ARG WEBVOWL_GIT_REF=28e7dd9540622e8cb723dc000824b5eef5ae775f
ARG OWL2VOWL_GIT_URL=https://github.com/VisualDataWeb/OWL2VOWL.git
ARG OWL2VOWL_GIT_REF=master

# --- OWL2VOWL: Spring Boot WAR (Java 8 code base) -------------------------------------------
FROM maven:${MAVEN_IMAGE} AS owl2vowl-builder
ARG OWL2VOWL_GIT_URL
ARG OWL2VOWL_GIT_REF
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*
WORKDIR /build/owl2vowl
RUN git clone --depth 1 --branch "${OWL2VOWL_GIT_REF}" "${OWL2VOWL_GIT_URL}" . 2>/dev/null \
 || (git clone "${OWL2VOWL_GIT_URL}" . && git checkout "${OWL2VOWL_GIT_REF}")
RUN mvn -B -q package -P war-release -DskipTests

# --- WebVOWL: Grunt/Webpack 1 build -> deploy/ ----------------------------------------------
FROM node:${NODE_IMAGE} AS webvowl-builder
ARG WEBVOWL_GIT_URL
ARG WEBVOWL_GIT_REF
RUN apk add --no-cache git
WORKDIR /build/webvowl
RUN git clone "${WEBVOWL_GIT_URL}" . && git checkout "${WEBVOWL_GIT_REF}"
RUN npm install --ignore-scripts && npm run release

# --- Explode the WAR with a JDK ---------------------------------------------------------------
FROM tomcat:${TOMCAT_VERSION}-jdk8-temurin-noble AS owl2vowl-expand
RUN rm -rf "${CATALINA_HOME}/webapps/"* && mkdir -p "${CATALINA_HOME}/webapps/ROOT"
COPY --from=owl2vowl-builder /build/owl2vowl/target/owl2vowl.war /tmp/owl2vowl.war
RUN cd "${CATALINA_HOME}/webapps/ROOT" && jar xf /tmp/owl2vowl.war && rm /tmp/owl2vowl.war

# --- Runtime ------------------------------------------------------------------------------------
FROM tomcat:${TOMCAT_VERSION}-jre8-temurin-noble
LABEL org.opencontainers.image.title="WebVOWL" \
      org.opencontainers.image.description="WebVOWL with OWL2VOWL converter (single Tomcat ROOT)" \
      org.opencontainers.image.source="https://github.com/MetaCoding-io/semantic-stack"

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd -r tomcat --gid=999 \
 && useradd -r -g tomcat --uid=999 --home-dir="${CATALINA_HOME}" tomcat \
 && rm -rf "${CATALINA_HOME}/webapps/"* \
 && mkdir -p "${CATALINA_HOME}/webapps/ROOT" /data \
 && chown -R tomcat:tomcat "${CATALINA_HOME}" /data

COPY --from=owl2vowl-expand --chown=tomcat:tomcat /usr/local/tomcat/webapps/ROOT/ /usr/local/tomcat/webapps/ROOT/
COPY --from=webvowl-builder --chown=tomcat:tomcat /build/webvowl/deploy/ /usr/local/tomcat/webapps/ROOT/

USER tomcat
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=90s --retries=3 \
  CMD curl -f http://127.0.0.1:8080/serverTimeStamp || exit 1
CMD ["catalina.sh", "run"]
