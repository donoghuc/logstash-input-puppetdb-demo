#/bin/bash


openssl pkcs8 -topk8 -nocrypt -in ./puppet_ssl/private_keys/puppet.pem -out ./puppet_ssl/private_keys/puppet.key