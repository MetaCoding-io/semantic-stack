# Ontop with the PostgreSQL JDBC driver baked in (the upstream image ships no drivers).
ARG ONTOP_VERSION=5.5.0
ARG PGJDBC_VERSION=42.7.14
FROM ontop/ontop:${ONTOP_VERSION}
ARG PGJDBC_VERSION
USER root
ADD --chown=ontop:ontop https://repo1.maven.org/maven2/org/postgresql/postgresql/${PGJDBC_VERSION}/postgresql-${PGJDBC_VERSION}.jar /opt/ontop/jdbc/postgresql-${PGJDBC_VERSION}.jar
USER ontop
