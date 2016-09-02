default[:use_statsd] = true
default[:chef_tsdb_gw]['log_level'] = 2
default[:chef_tsdb_gw]['addr'] = ":8081"
default[:chef_tsdb_gw]['ssl'] = false
default[:chef_tsdb_gw]['cert_file'] = ""
default[:chef_tsdb_gw]['key_file'] = ""
default[:chef_tsdb_gw]['real_ssl_cert'] = false
default[:chef_tsdb_gw]['ssl_data_bag'] = node.fqdn
default[:chef_tsdb_gw]['stats_enabled'] = true
default[:chef_tsdb_gw]['statsd_addr'] = "localhost:8125"
default[:chef_tsdb_gw]['statsd_type'] = "standard"
default[:chef_tsdb_gw]['admin_key'] = "CHANGEME"
default[:chef_tsdb_gw]['kafka_tcp_addr'] = "localhost:9092"
default[:chef_tsdb_gw]['kafka_comp'] = "none"
default[:chef_tsdb_gw]['metric_topic'] = "mdm"
default[:chef_tsdb_gw]['publish_metrics'] = true
default[:chef_tsdb_gw]['event_topic'] = "events"
default[:chef_tsdb_gw]['publish_events'] = true
default[:chef_tsdb_gw]['graphite_url'] = "http://localhost:8888/"
default[:chef_tsdb_gw]['worldping_url'] = "https://worldping-api.raintank.io/"
default[:chef_tsdb_gw]['elasticsearch_url'] = "http://localhost:9200/"
default[:chef_tsdb_gw]['es_index'] = "events"

# nginx
default[:chef_tsdb_gw][:domain] = "localhost"
default[:chef_tsdb_gw][:aliases] = []
default[:chef_tsdb_gw][:backend] = "localhost:8081"
default[:chef_tsdb_gw][:nginx][:use_ssl] = false
default[:chef_tsdb_gw][:nginx][:ssl_cert_file] = "/etc/nginx/ssl/tsdb-gw.crt"
default[:chef_tsdb_gw][:nginx][:ssl_key_file] = "/etc/nginx/ssl/tsdb-gw.key"
default[:chef_tsdb_gw][:nginx][:ssl_data_bag] = node[:chef_tsdb_gw][:domain]

override[:nginx][:client_max_body_size] = "10m"
