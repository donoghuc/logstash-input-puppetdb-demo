#!/bin/bash

BASE_DIR="/Users/cas/spacetime/logstash-input-puppetdb-demo"
CERT_DIR="$BASE_DIR/puppet_ssl"
OUTPUT_DIR="$BASE_DIR/example_pdb_data"

mkdir -p $OUTPUT_DIR

curl --insecure \
--cacert $CERT_DIR/certs/ca.pem \
--cert $CERT_DIR/certs/puppet.pem \
--key $CERT_DIR/private_keys/puppet.key \
-H "Content-Type: application/json" \
https://localhost:8081/pdb/query/v4/nodes | jq > $OUTPUT_DIR/nodes.json

curl --insecure \
--cacert $CERT_DIR/certs/ca.pem \
--cert $CERT_DIR/certs/puppet.pem \
--key $CERT_DIR/private_keys/puppet.key \
-H "Content-Type: application/json" \
-d '{"query": ["=", "certname", "agent1.puppet"], "order_by": [{"field": "name", "order": "asc"}]}' \
https://localhost:8081/pdb/query/v4/facts | jq > $OUTPUT_DIR/facts.json

curl --insecure \
--cacert $CERT_DIR/certs/ca.pem \
--cert $CERT_DIR/certs/puppet.pem \
--key $CERT_DIR/private_keys/puppet.key \
-H "Content-Type: application/json" \
-d '{"query": ["=", "certname", "agent1.puppet"], "order_by": [{"field": "receive_time", "order": "desc"}], "limit": 1}' \
https://localhost:8081/pdb/query/v4/reports | jq > $OUTPUT_DIR/reports.json

curl --insecure \
--cacert $CERT_DIR/certs/ca.pem \
--cert $CERT_DIR/certs/puppet.pem \
--key $CERT_DIR/private_keys/puppet.key \
-H "Content-Type: application/json" \
-d '{"query": ["=", "certname", "agent1.puppet"], "order_by": [{"field": "transaction_uuid", "order": "desc"}], "limit": 1}' \
https://localhost:8081/pdb/query/v4/catalogs | jq > $OUTPUT_DIR/catalogs.json