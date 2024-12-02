FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y wget ca-certificates lsb-release && \
    wget https://apt.puppet.com/puppet8-release-jammy.deb && \
    dpkg -i puppet8-release-jammy.deb && \
    apt-get update && \
    apt-get install -y puppet-agent && \
    apt-get install -y netcat-traditional && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENV PUPPET_AGENT_STARTUP_SLEEP=10
ENTRYPOINT ["/docker-entrypoint.sh"]