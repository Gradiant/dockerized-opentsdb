This is a docker image of [OpenTSDB](http://opentsdb.net/) The Scalable Time Series Database.


## Properties

- This image has a small footprint ( base docker image is openjdk:8u171-jre-alpine3.8).


## Howto


You can configure following properties through environment variables:

- JAVA_OPTS. Default is "-Xms512m -Xmx2048m"
- ZKQUORUM. Default is localhost:2181
- ZKBASEDIR. Default is /hbase
- TSDB_PORT. Default is 4242

For advanced configuration, you can also provide an opentsdb.conf file in /etc/opentsdb/opentsdb.conf container path.
More info at [OpenTSDB Documentation](http://opentsdb.net/docs/build/html/user_guide/configuration.html)

```
docker run -d -v $PWD/opentsdb.conf:/etc/opentsdb/opentsdb.conf gradiant/opentsdb:2.3.1
```



## Example of usage


```
docker-compose up -d
```


