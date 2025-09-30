require 'elasticsearch/model'

# Configure Elasticsearch
config = {
  host: ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200'),
  transport_options: {
    request: { timeout: 5 }
  },
  retry_on_failure: true,
  log: true
}

if File.exist?('config/elasticsearch.yml')
  custom_config = YAML.load_file('config/elasticsearch.yml')[Rails.env]
  config.merge!(custom_config.symbolize_keys) if custom_config
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)