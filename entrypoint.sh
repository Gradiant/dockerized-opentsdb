#!/bin/bash

set -ex

CLASSPATH=$OPENTSDB_PREFIX:$OPENTSDB_PREFIX/tsdb-$OPENTSDB_VERSION.jar:$OPENTSDB_PREFIX/libs/*:$OPENTSDB_PREFIX/logback.xml
STATICROOT=$OPENTSDB_PREFIX/static
CACHEDIR=/tmp/opentsdb

#Configuration through environment variable takes precedence
if [[ -v "${TSDB_PORT}" ]]; then
   TSDB_OPTS="$TSDB_OPTS --port=$TSDB_PORT"
elif ! grep -q "^tsd.network.port="; then
   echo "Setting TSDB PORT to default value 4242"
   TSDB_OPTS="$TSDB_OPTS --port=4242"
fi

if [[ -v "${ZKQUORUM}" ]]; then
  TSDB_OPTS="$TSDB_OPTS --zkquorum=$ZKQUORUM"
fi

if [[ -v "${ZKBASEDIR}" ]]; then
   TSDB_OPTS="$TSDB_OPTS --zkbasedir=$ZKBASEDIR"
fi

java $JAVA_OPTS -enableassertions -enablesystemassertions -classpath $CLASSPATH net.opentsdb.tools.TSDMain --staticroot=$STATICROOT --cachedir=$CACHEDIR $TSDB_OPTS

