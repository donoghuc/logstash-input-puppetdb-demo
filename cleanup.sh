#!/bin/bash

# Stop containers and remove volumes
docker-compose down -v

# Remove SSL directories
rm -rf puppet_ssl puppet_ca 

# Recreate directories
mkdir -p puppet_ssl puppet_ca puppet_code/puppet/ca

# Create CA configuration
cat > puppet_code/puppet/ca/ca.conf << EOL
allow-subject-alt-names: true
EOL
