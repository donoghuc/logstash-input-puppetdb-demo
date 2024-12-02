# logstash/Dockerfile
FROM docker.elastic.co/logstash/logstash:8.12.0

USER root

RUN apt-get update && \
    apt-get install -y gosu build-essential ruby-dev && \
    rm -rf /var/lib/apt/lists/*
# Install puppet_facter plugin
# TODO: replace this once we have a logstash-input-puppetdb plugin published
RUN /usr/share/logstash/bin/logstash-plugin install logstash-input-puppet_facter

WORKDIR /usr/share/logstash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]