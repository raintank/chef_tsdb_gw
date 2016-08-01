packagecloud_repo node[:chef_base][:packagecloud_repo] do
  type "deb"
end

proxy = find_haproxy || ''

if !proxy.empty?
	node.override['chef_tsdb_gw']['elasticsearch_url'] = "http://#{proxy}:9200/"
	node.override['chef_tsdb_gw']['graphite_url'] = "http://#{proxy}:8888/"
	node.override['chef_tsdb_gw']['kafka_tcp_addr'] = "#{proxy}:9092"
end

pkg_version = node['chef_tsdb_gw']['version']
pkg_action = if pkg_version.nil?
  :upgrade
else
  :install
end

package "tsdb-gw" do
  version pkg_version
  action pkg_action
  notifies :restart, 'service[tsdb-gw]', :delayed
end

service "tsdb-gw" do
  case node["platform"]
  when "ubuntu"
    if node["platform_version"].to_f >= 15.04
      provider Chef::Provider::Service::Systemd
    elsif node["platform_version"].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end
  action [ :enable, :start]
end

nspace = {
  'key_path' => node['chef_tsdb_gw']['key_file'],
  'cert_path' => node['chef_tsdb_gw']['cert_file'],
  'key_dir' => "/etc/raintank",
  'cert_dir' => "/etc/raintank",
  'common_name' => node.name
}

if node['chef_tsdb_gw']['ssl']
  if node['chef_tsdb_gw']['real_ssl_cert']
    certs = Chef::EncryptedDataBagItem.load(:grafana_ssl_certs, node['chef_tsdb_gw']['ssl_data_bag']).to_hash
    file node['chef_tsdb_gw']['cert_file'] do
      owner "root"
      group "root"
      mode '0600'
      content certs['ssl_cert']
      action :create
    end
    file node['chef_tsdb_gw']['key_file'] do
      owner "root"
      group "root"
      mode '0600'
      content certs['ssl_key']
      action :create
    end
  else
    cert = ssl_certificate "tsdb-#{node.name}" do
      namespace nspace
      notifies :restart, 'service[tsdb-gw]', :delayed
    end

    node.set['chef_tsdb_gw']['cert_file'] = cert.cert_path
    node.set['chef_tsdb_gw']['key_file'] = cert.key_path
  end
end

template "/etc/raintank/tsdb.ini" do
  source 'tsdb.ini.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  # notifies ....
  notifies :restart, 'service[tsdb-gw]', :delayed
end

tag("tsdb")
