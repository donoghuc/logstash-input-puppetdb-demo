Steps:

```
# run cleanup script
./cleanup.sh
# Once you have certs generated key convert
./key-converter.sh
# Run logstash
bin/logstash -f ../../spacetime/logstash-input-puppetdb-demo/logstash/puppetdb-demo-pipeline.conf
```

Import xport.ndjson in kibana
http://0.0.0.0:5601/