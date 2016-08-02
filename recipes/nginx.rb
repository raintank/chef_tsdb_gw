#
# Cookbook Name:: chef_tsdb_gw
# Recipe:: nginx
#
# Copyright (C) 2016 Raintank, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'nginx::repo'
include_recipe 'nginx'

# create ssl cert files if we're doing that
if node['chef_tsdb_gw']['nginx']['use_ssl']
  directory "/etc/nginx/ssl" do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0700'
    action :create
  end

  # Later: this should use chef-vault instead of encrypted data bags
  certs = Chef::EncryptedDataBagItem.load(:grafana_ssl_certs, node['chef_tsdb_gw']['nginx']['ssl_data_bag']).to_hash
  cert_file = node['chef_tsdb_gw']['nginx']['ssl_cert_file']
  cert_key = node['chef_tsdb_gw']['nginx']['ssl_key_file']
  file node['chef_tsdb_gw']['nginx']['ssl_cert_file'] do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0600'
    content certs['ssl_cert']
    action :create
  end
  file node['chef_tsdb_gw']['nginx']['ssl_key_file'] do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0600'
    content certs['ssl_key']
    action :create
  end
end

# nginx on first boot
execute "nginx-stop-and-kill" do
  creates "/etc/nginx/firstboot"
  command "touch /etc/nginx/firstboot && service nginx stop && killall -9 nginx || echo 'not killed'"
  ignore_failure true
  notifies :start, "service[nginx]", :immediately
end

gn_source = if node['chef_tsdb_gw']['nginx']['use_ssl']
  "app_tsdb_gw_ssl.conf.erb"
else
  "app_tsdb_gw.conf.erb"
end

template "/etc/nginx/sites-available/tsdb_gw" do
  source gn_source
end

nginx_site 'default' do
  enable false
end

nginx_site "tsdb_gw" do
  notifies :restart, 'service[nginx]'
end
