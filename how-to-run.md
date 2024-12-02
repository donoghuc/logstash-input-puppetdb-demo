## How to run this demo locally

The idea for this demo is ultimately to encapsulate everything in a docker-compose file such that anybody can run this without needing to know about deploying Puppet or Elastic. Currently there is one wrinke with this whereby logstash is running outside the compose manifest. This will be solved as soon as a preview version of the plugin is published to rubygems. 

## Overview

The docker-compose manifest encodes a simple puppet deployment consisting of a Puppetserver, PuppetDB and 6 Puppet Agents. Agents are configured to check in every minute for the demo. Elastic and Kibana are deployed and ready to accept data input from logstash. 

## Running
1. After cloning this repo, run `cleanup.sh` which takes care of ensuring docker is in the right state and any of the volume data is purged. 
2. Start a new compose cluster with `docker compose up --build` (this will stream logs from all the services)
3. Once the logs from 2 indicate agents are checking in you are ready to start up Logstash. Logstash needs a key in a particular format so run the `key-converter.sh` script to generate this. NOTE: This is just re-using a puppet cert. Once I get around to encoding everything in the docker-compose manifest I will actually use the Puppet CA to generate a cert for Logstash
4. Configure logstash pipeline. Example configuration can be found in [puppetdb-demo-pipeline.conf](./logstash/puppetdb-demo-pipeline.conf)
5. Build logstash. The only way I know how to use a plugin *NOT* published to Rubygems is to build it in locally to logstash. Roughly that looks like checking out the head of 8.x for logstash repo, updating the gemspec to point to the plugin (plugin code in logstash-input-puppetdb), then build with `./gradlew clean bootstrap assemble installDefaultGems` 
6. Start logstash pointing it at the pipeline config file `bin/logstash -f ../../spacetime/logstash-input-puppetdb-demo/logstash/puppetdb-demo-pipeline.conf` 
7. Once we have data we can visualize in Kibana. Open http://0.0.0.0:5601/ and import `xport.ndjson` in the Kibana UI under "Stack Management". 

## TODO

As mentioned, once I have a demo version published I should be able to encode everything such that the entire setup is simply running docker compose. This will be a requirement for an effective blog post. 