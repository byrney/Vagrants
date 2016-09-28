include_recipe "ckan::ckan_base"
include_recipe "ckan::ckan_datastore"

# Create a production.ini file.
file "#{node[:ckan][:config_dir]}/production.ini" do
  content IO.read("#{node[:ckan][:config_dir]}/development.ini")
  action :create
end

# Install and configure apache
package "apache2" do
    action :install
end
package "libapache2-mod-rpaf" do
    action :install
end
package "libapache2-mod-wsgi" do
    action :install
end
template "#{node[:ckan][:config_dir]}/apache.wsgi" do
    source "apache.wsgi.erb"
    variables({
        :source_dir => node[:ckan][:virtual_env_dir]
    })
end
template "/etc/apache2/sites-available/ckan_#{node[:ckan][:project_name]}" do
    source "apache_site_tmpl.erb"
    variables({
        :project_name => node[:ckan][:project_name],
        :server_name => node[:apache][:server_name],
        :server_alias => node[:apache][:server_alias],
        :config_dir => node[:ckan][:config_dir]
    })
end
# replace ports.conf
template "/etc/apache2/ports.conf" do
    source "apache_ports_conf.erb"
end
# enable site, and disable default
execute "enable apache site" do
    command "sudo a2ensite ckan_#{node[:ckan][:project_name]}"
end
execute "disable default apache site" do
    command "sudo a2dissite default"
end

# Install and configure Nginx
package "nginx" do
    action :install
end
# enable site, and disable default
template "/etc/nginx/sites-available/ckan_#{node[:ckan][:project_name]}" do
    source "nginx_site_tmpl.erb"
end
file "/etc/nginx/sites-enabled/default" do
    action :delete
end
link "/etc/nginx/sites-enabled/ckan_#{node[:ckan][:project_name]}" do
  to "/etc/nginx/sites-available/ckan_#{node[:ckan][:project_name]}"
  action :create
end

package "postfix" do
    action :install
end

# give jetty a kick
service "jetty" do
  supports :status => true, :restart => true, :reload => true
  action [:restart]
end

service "apache2" do
  supports :restart => true, :reload => true
  action [:enable, :restart]
end
service "nginx" do
  supports :restart => true, :reload => true
  action [:enable, :restart]
end
