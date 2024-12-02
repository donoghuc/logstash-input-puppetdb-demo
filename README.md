# Logstash PuppetDB input plugin POC Demo

This Demo describes the outcome of an On Week (11/25-11/27 2024) project descrived in https://github.com/elastic/ingest-dev/issues/4491

## PuppetDB verview

```mermaid
flowchart LR
    subgraph Agent["Puppet Agent"]
        facts["Facts"]
    end

    subgraph Server["Puppet Server"]
        compiler["Catalog Compiler"]
    end

    subgraph DB["PuppetDB"]
        stored_facts["Stored Facts"]
        stored_reports["Stored Reports"]
        stored_resources["Stored Resources"]
    end

    %% Facts flow
    facts -->|"1. Facts Upload"| Server
    Server -->|"2. Store Facts"| stored_facts

    %% Catalog compilation and application
    Server -->|"3. Compile Catalog"| compiler
    compiler -->|"4. Return Catalog"| Agent

    %% Report flow
    Agent -->|"5. Send Report"| Server
    Server -->|"6. Store Report"| stored_reports

    %% Resource recording
    Server -->|"7. Store Resources"| stored_resources

    style Agent fill:#e6f3ff,stroke:#4a90e2
    style Server fill:#f5e6ff,stroke:#9b59b6
    style DB fill:#e6ffe6,stroke:#2ecc71
```
1. Puppet agent collects facts about the system and sends them to the Puppet server
2. Puppet server stores these facts in PuppetDB
3. Perver compiles a catalog for the agent
4. Catalog is sent back to the agent for application
5. After applying the catalog, the agent sends a report back to the server
6. The server stores the report in PuppetDB
7. Resource data is also stored in PuppetDB for querying

- With this architecture a wealth of information is stored in PuppetDB (we will focus first on `facts`, `catalogs`, and `reports`).

- An both open source deployments as well as enterprise use the same PuppetDB API. 

- Puppet Enterpise offers overview features (report viewer, facts viewer) proving this is valuable. 

- A plugin for ingesting this data to ELK could benefit both enterprise and OS users. 

## Plugin design

The existing [puppet_facter](https://github.com/logstash-plugins/logstash-input-puppet_facter) plugin queried puppetserver for facts which is deprecated. 

The first iteration of the plugin was simply to periodically query PuppetDB and transform the data in logical events. For this first pass that basically boiled down to this very simple strategy:

1. Ask PuppetDB for all the nodes it knows about
2. Take that list of nodes and query for its last facts, catalog, and report
3. Compile an event consisting of a nodes information gathered in step 2 and send it along in the pipeline.

## Plugin improvements

1. Scalability: batch nodes and use pagination
2. Flexibility: Allow fine grained control of what to collect, perhaps expose a way to run user provided AST against a desired endpoint. 
3. Feedback: Get a release on rubygems and ask PuppetDB maintainers and Puppet users for feedback

## How can I help?

1. I'm new, and as sure I'm not doing things idiomatically or am unaware of best practices, please point these out! 
2. If you have a knack for data visualization I would love some help building out visuals that are compelling for a blog post. 

