FROM openjdk:8u171-jdk-alpine3.8 as builder
LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"

ARG VERSION=2.3.1
ENV VERSION=$VERSION

RUN apk add --no-cache bash build-base autoconf automake python && mkdir /opt
# building opentsdb

RUN wget -qO- https://github.com/OpenTSDB/opentsdb/archive/v$VERSION.tar.gz | tar xvz -C /opt
ENV TARGET=/opt/target
ENV WORKDIR=/usr/share/opentsdb
ENV ETCDIR=/etc/opentsdb

RUN cd /opt/opentsdb-$VERSION && ./build.sh
RUN mkdir -p $TARGET$WORKDIR && \
    mkdir -p $TARGET$WORKDIR/bin && \
    mkdir -p $TARGET$WORKDIR/libs && \
    mkdir -p $TARGET$WORKDIR/static && \
    mkdir -p $TARGET$ETCDIR
RUN cd /opt/opentsdb-$VERSION && \
    cp src/logback.xml $TARGET$WORKDIR && \
    cp src/mygnuplot.sh $TARGET$WORKDIR && \
    cp build/tsdb-2.3.1.jar $TARGET$WORKDIR && \
    cp build/tsdb $TARGET$WORKDIR/bin/ && \
    cp build/third_party/*/*.jar $TARGET$WORKDIR/libs/ && \
    cp -rL build/staticroot/* $TARGET$WORKDIR/static && \
    cd $TARGET && tar -cvzf /docker-opentsdb.tgz .

FROM openjdk:8u171-jre-alpine3.8

LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"

ARG VERSION=2.3.1

ENV       OPENTSDB_VERSION=$VERSION
ENV       OPENTSDB_PREFIX /usr/share/opentsdb
ENV       LOGDIR  /var/log/opentsdb

# It is expected these might need to be passed in with the -e flag
ENV       JAVA_OPTS="-Xms512m -Xmx2048m"

WORKDIR   $OPENTSDB_PREFIX

COPY --from=builder /docker-opentsdb.tgz /
RUN tar -xvzf /docker-opentsdb.tgz -C / && apk add --no-cache bash

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
