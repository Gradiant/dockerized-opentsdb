This is a docker image of [OpenTSDB](http://opentsdb.net/) The Scalable Time Series Database.


## Properties

- This image has a small footprint ( base docker image is openjdk:8u171-jre-alpine3.8).


## Howto


Configuration is through environment variables:

- JAVA_OPTS. Default is "-Xms512m -Xmx2048m"
- ZKQUORUM. Default is zookeeper:2181
- ZKBASEDIR. Default is /hbase
- TSDB_OPTS. Default is "--read-only --disable-ui"
- TSDB_PORT. Default is 4244


## Example of usage


```
docker-compose up -d
```


