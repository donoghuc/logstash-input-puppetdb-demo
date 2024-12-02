#!/bin/bash
set -e

echo "[Entrypoint] Starting Logstash setup..."

# Create local SSL directory
LOCAL_SSL_DIR="/opt/logstash/ssl"
mkdir -p $LOCAL_SSL_DIR

# Wait for any puppet agent certificate
echo "[Entrypoint] Waiting for puppet certificates..."
until find /etc/puppetlabs/puppet/ssl/certs -name "*.pem" | grep -q .; do
    echo "[Entrypoint] No certificates found, waiting..."
    sleep 5
done

echo "[Entrypoint] Found certificates, copying to local directory..."
cp -r /etc/puppetlabs/puppet/ssl/* $LOCAL_SSL_DIR/

echo "[Entrypoint] Setting permissions on local certificates..."
chown -R logstash:logstash $LOCAL_SSL_DIR

# Update Logstash SSL path in config
export LOGSTASH_SSL_DIR=$LOCAL_SSL_DIR

echo "[Entrypoint] Starting Logstash..."
exec gosu logstash logstash