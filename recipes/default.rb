#
# Cookbook:: haproxy_loadbalancer
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

apt_update
package 'net-tools'
haproxy_install 'package'

haproxy_frontend 'http-in' do
  bind '*:80'
  default_backend 'servers'
end

web_node_objects = search('node', "policy_name:webserver AND policy_group:#{node['policy_group']}")

web_servers = []
web_node_objects.each do |one_node|
  server = "#{one_node['cloud']['public_hostname']} #{one_node['cloud']['public_ipv4']}:80 check"
  web_servers.push(server)
end
# NOTE: the line where you set the "server" variable in the .each loop
# above is all on one line, with a space between the hostname and the
# public_ip, and the word 'check', like this: server = "#{one_node['cloud']['public_hostname']} #{one_node['cloud']['public_ipv4']}:80 check"

haproxy_backend 'servers' do
  server web_servers
end

haproxy_service 'haproxy' do
  subscribes :reload, 'template[/etc/haproxy/haproxy.cfg]', :delayed
end
