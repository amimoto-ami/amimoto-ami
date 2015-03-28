#
# Cookbook Name:: amimoto
# Recipe:: default
#
# Copyright 2013, DigitalCube Co. Ltd.
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'amimoto::timezone'
include_recipe 'amimoto::iptables'
include_recipe 'amimoto::sysctl'
include_recipe 'amimoto::repos'
template "/etc/sysconfig/i18n" do
  source "i18n.erb"
end
#template "/etc/sudoers" do
#  source "sudoers.erb"
#end

%w{ zip unzip wget git openssl bash }.each do | pkg |
  package pkg do
    action [:install, :upgrade]
  end
end

%w{httpd24 httpd24-tools}.each do | pkg |
  package pkg do
    action [:remove]
  end
end

# memcached install
node[:memcached][:packages].each do | pkg |
  package pkg do
    action [:install, :upgrade]
    options '--disablerepo=remi'
  end
end
service "memcached" do
  action node[:memcached][:service_action]
end

# install mysql
include_recipe 'amimoto::mysql'

# install nginx
include_recipe 'amimoto::nginx'
#include_recipe 'amimoto::nginx_default'

# install php
if node[:hhvm][:enabled]
  include_recipe 'amimoto::hhvm'
else
  include_recipe 'amimoto::php'
end

# install monit
include_recipe 'amimoto::monit'

# install wp-cli
include_recipe 'amimoto::wpcli'
# install php
if node[:hhvm][:enabled]
  if (node.memory.total.to_i / 1024) > 1024
    include_recipe 'amimoto::redis_hhvm'
  end
end
