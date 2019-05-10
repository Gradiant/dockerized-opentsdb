FROM openjdk:8u212-jdk-alpine3.9 as builder
LABEL maintainer="cgiraldo@gradiant.org"
LABEL organization="gradiant.org"

ARG VERSION=2.4.0
ENV VERSION=$VERSION

RUN apk add --no-cache bash build-base autoconf automake python && mkdir -p /opt
# building opentsdb

RUN wget -qO- https://github.com/OpenTSDB/opentsdb/archive/v$VERSION.tar.gz | tar xvz -C /opt
RUN ln -s /opt/opentsdb-$VERSION /opt/opentsdb

RUN cd /opt/opentsdb-$VERSION && ./build.sh
RUN mkdir -p /opt/opentsdb/dist/usr/share/opentsdb/bin && \
    mkdir -p /opt/opentsdb/dist/usr/share/opentsdb/lib && \
    mkdir -p /opt/opentsdb/dist/usr/share/opentsdb/plugins && \
    mkdir -p /opt/opentsdb/dist/usr/share/opentsdb/static && \
    mkdir -p /opt/opentsdb/dist/usr/share/opentsdb/tools && \
    mkdir -p /opt/opentsdb/dist/etc/opentsdb && \
    mkdir -p /var/log/opentsdb
RUN cd /opt/opentsdb-$VERSION && \
    cp src/opentsdb.conf /opt/opentsdb/dist/etc/opentsdb/ && \
    cp src/logback.xml /opt/opentsdb/dist/etc/opentsdb/ && \
    cp src/mygnuplot.sh /opt/opentsdb/dist/usr/share/opentsdb/bin && \
    cp build/tsdb-2.4.0.jar /opt/opentsdb/dist/usr/share/opentsdb/lib && \
    cp build/tsdb /opt/opentsdb/dist/usr/share/opentsdb/bin/ && \
    cp build/third_party/*/*.jar /opt/opentsdb/dist/usr/share/opentsdb/lib/ && \
    cp -rL build/staticroot/* /opt/opentsdb/dist/usr/share/opentsdb/static
RUN sed -i "s@pkgdatadir=''@pkgdatadir='/usr/share/opentsdb'@g" /opt/opentsdb/dist/usr/share/opentsdb/bin/tsdb
RUN sed -i "s@configdir=''@configdir='/etc/opentsdb'@g" /opt/opentsdb/dist/usr/share/opentsdb/bin/tsdb
# Set Configuration Defaults
RUN sed -i "s@tsd.network.port =.*@tsd.network.port = 4242@g" /opt/opentsdb/dist/etc/opentsdb/opentsdb.conf
RUN sed -i "s@tsd.http.staticroot =.*@tsd.http.staticroot = /usr/share/opentsdb/static/@g" /opt/opentsdb/dist/etc/opentsdb/opentsdb.conf
RUN sed -i "s@tsd.http.cachedir =.*@tsd.http.cachedir = /tmp/opentsdb@g" /opt/opentsdb/dist/etc/opentsdb/opentsdb.conf
RUN sed -i '/CORE.*/a # Full path to a directory containing plugins for OpenTSDB\ntsd.core.plugin_path = /usr/share/opentsdb/plugins/' /opt/opentsdb/dist/etc/opentsdb/opentsdb.conf 

## Build GNUPLOT from source to enable png terminal
# https://github.com/PeterGrace/opentsdb-docker/pull/26
ENV GNUPLOT_VERSION 5.2.4
RUN apk add --no-cache cairo-dev pango-dev gd-dev lua-dev readline-dev libpng-dev libjpeg-turbo-dev libwebp-dev
RUN cd /opt && \
    wget https://datapacket.dl.sourceforge.net/project/gnuplot/gnuplot/${GNUPLOT_VERSION}/gnuplot-${GNUPLOT_VERSION}.tar.gz && \
    tar xzf gnuplot-${GNUPLOT_VERSION}.tar.gz && \
    ln -s /opt/gnuplot-${GNUPLOT_VERSION} /opt/gnuplot && \
    cd /opt/gnuplot && \
    ./configure --prefix=/opt/gnuplot/dist && \
    make &&  make install && rm -r /opt/gnuplot/dist/share/man


FROM  openjdk:8u212-jre-alpine3.9

LABEL maintainer="cgiraldo@gradiant.org" \
      organization="gradiant.org"

ENV OPENTSDB_VERSION=2.4.0 \
    OPENTSDB_PREFIX=/usr/share/opentsdb \
    LOGDIR=/var/log/opentsdb \
    PATH=$PATH:/usr/share/opentsdb/bin
# It is expected these might need to be passed in with the -e flag
ENV       JAVA_OPTS="-Xms512m -Xmx2048m"

WORKDIR   $OPENTSDB_PREFIX

COPY --from=builder /opt/opentsdb/dist /
COPY --from=builder /opt/gnuplot/dist /

RUN apk add --no-cache bash libgd libpng libjpeg libwebp libjpeg-turbo cairo pango lua

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

