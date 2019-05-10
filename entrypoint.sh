#!/bin/bash

set -ex

#Configuration through environment variable takes precedence
if [[ ! -z "${TSDB_PORT}" ]]; then
   TSDB_OPTS="$TSDB_OPTS --port=$TSDB_PORT"
fi

if [[ ! -z "${ZKQUORUM}" ]]; then
  TSDB_OPTS="$TSDB_OPTS --zkquorum=$ZKQUORUM"
fi

if [[ ! -z "${ZKBASEDIR}" ]]; then
   TSDB_OPTS="$TSDB_OPTS --zkbasedir=$ZKBASEDIR"
fi

/usr/share/opentsdb/bin/tsdb tsd start $TSDB_OPTS


