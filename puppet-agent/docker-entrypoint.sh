#!/bin/bash

# Configure puppet agent
/opt/puppetlabs/bin/puppet config set server $PUPPET_SERVER --section main
/opt/puppetlabs/bin/puppet config set certname $HOSTNAME --section main

# Function to check server availability
check_server() {
    nc -z $PUPPET_SERVER 8140
    return $?
}

# Wait for Puppet server to be available
MAX_RETRIES=30
count=0
while ! check_server; do
    count=$((count+1))
    if [ $count -eq $MAX_RETRIES ]; then
        echo "Puppet server not available after 5 minutes, exiting"
        exit 1
    fi
    echo "Waiting for Puppet server to become available... (attempt $count/$MAX_RETRIES)"
    sleep 10
done

# Initial puppet run with retries
for i in {1..5}; do
    echo "Attempting initial Puppet run (attempt $i/5)"
    /opt/puppetlabs/bin/puppet agent --test --noop && break
    if [ $i -eq 5 ]; then
        echo "Failed to complete initial Puppet run after 5 attempts"
    fi
    sleep 10
done

# Set run interval to 1 min for demo
/opt/puppetlabs/bin/puppet config set runinterval 60 --section agent

# Start puppet agent in foreground
exec /opt/puppetlabs/bin/puppet agent --no-daemonize --verbose