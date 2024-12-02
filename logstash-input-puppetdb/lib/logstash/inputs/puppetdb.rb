# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "logstash/plugin_mixins/scheduler"
require "manticore"
require "json"
require "fileutils"
require "time"

class LogStash::Inputs::Puppetdb < LogStash::Inputs::Base
  include LogStash::PluginMixins::Scheduler

  config_name "puppetdb"
  
  default :codec, "json"

  # PuppetDB connection settings
  config :host, :validate => :string, :required => true
  config :port, :validate => :number, :default => 8081
  
  # SSL Settings
  config :ssl_enabled, :validate => :boolean, :default => true
  config :ssl_verify, :validate => :boolean, :default => false
  config :ssl_certificate_authorities, :validate => :path, :list => true
  config :ssl_certificate, :validate => :path
  config :ssl_key, :validate => :path
  config :ssl_supported_protocols, :validate => ['TLSv1.1', 'TLSv1.2', 'TLSv1.3'], :default => ['TLSv1.2'], :list => true

  # Schedule of when to poll PuppetDB
  config :schedule, :validate => :hash, :required => true

  def register
    setup_urls
    setup_client
  end

  private

  def setup_urls
    @base_url = "https://#{@host}:#{@port}"
    @nodes_url = "#{@base_url}/pdb/query/v4/nodes"
    @facts_url = "#{@base_url}/pdb/query/v4/facts"
    @reports_url = "#{@base_url}/pdb/query/v4/reports"
    @catalogs_url = "#{@base_url}/pdb/query/v4/catalogs"
  end

  def setup_client
    @client = Manticore::Client.new({
      ssl: {
        ca_file: @ssl_certificate_authorities&.first,
        client_cert: @ssl_certificate,
        client_key: @ssl_key,
        verify: @ssl_verify,
        hostname_verification: false,
        protocols: @ssl_supported_protocols
      }
    })
  end

  def fetch_nodes
    response = @client.get(@nodes_url)
    if response.code == 200
      JSON.parse(response.body)
    else
      @logger.error("Failed to fetch nodes", code: response.code)
      []
    end
  end

  def normalize_data(data)
    case data
    when Hash
      data.transform_values { |v| normalize_data(v) }
    when Array
      data.map { |v| normalize_data(v) }
    when Integer
      data.to_f
    else
      data
    end
  end

  def fetch_facts(certname)
    query = {
      query: ["=", "certname", certname],
      order_by: [{"field" => "name", "order" => "asc"}]
    }.to_json

    response = @client.post(@facts_url, 
      body: query,
      headers: {"Content-Type" => "application/json"}
    )

    if response.code == 200
      facts_hash = {}
      JSON.parse(response.body).each do |fact|
        facts_hash[fact["name"]] = fact["value"]
      end
      normalize_data(facts_hash)
    else
      @logger.error("Failed to fetch facts", certname: certname, code: response.code)
      {}
    end
  end
  
  def fetch_latest_report(certname)
    query = {
      query: ["=", "certname", certname],
      order_by: [{"field" => "receive_time", "order" => "desc"}],
      limit: 1
    }.to_json
  
    response = @client.post(@reports_url,
      body: query,
      headers: {"Content-Type" => "application/json"}
    )
  
    if response.code == 200
      report = JSON.parse(response.body).first
      normalize_data(report)
    else
      @logger.error("Failed to fetch report", certname: certname, code: response.code)
      {}
    end
  end

  def fetch_latest_catalog(certname)
    query = {
      query: ["=", "certname", certname],
      order_by: [{"field" => "transaction_uuid", "order" => "desc"}],
      limit: 1
    }.to_json

    response = @client.post(@catalogs_url,
      body: query,
      headers: {"Content-Type" => "application/json"}
    )

    if response.code == 200
      catalog = JSON.parse(response.body).first
      normalize_data(catalog)
    else
      @logger.error("Failed to fetch catalog", certname: certname, code: response.code)
      {}
    end
  end

  def run_once(queue)
    @logger.info("Starting collection cycle")
    
    fetch_nodes.each do |node|
      certname = node["certname"]
      @logger.debug("Processing node", certname: certname)

      event = LogStash::Event.new(
        "certname" => certname,
        "environment" => node["environment"],
        "node_info" => node,
        "facts" => fetch_facts(certname),
        "latest_report" => fetch_latest_report(certname),
        "latest_catalog" => fetch_latest_catalog(certname),
        "@timestamp" => Time.now
      )

      decorate(event)
      queue << event
    end
  end

  public
  
  def run(queue)
    setup_schedule(queue)
  end

  def stop
    @client.close
  end

  def close
    @client.close
  end

  private

  def setup_schedule(queue)
    schedule_type = @schedule.keys.first
    schedule_value = @schedule[schedule_type]
    
    msg_invalid_schedule = "Invalid config. schedule hash must contain exactly one of the following keys - cron, at, every or in"
    raise LogStash::ConfigurationError, msg_invalid_schedule if @schedule.keys.length != 1
    raise LogStash::ConfigurationError, msg_invalid_schedule unless %w(cron every at in).include?(schedule_type)

    opts = schedule_type == "every" ? { first_in: 0.01 } : {}
    
    scheduler.public_send(schedule_type, schedule_value, opts) do
      run_once(queue)
    end
    
    scheduler.join
  end
end