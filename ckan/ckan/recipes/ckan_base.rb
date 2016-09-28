# Installs base ckan instance and sets up development.ini.

include_recipe "nodejs::nodejs_from_package"

ENV['VIRTUAL_ENV'] = node[:ckan][:virtual_env_dir]
ENV['PATH'] = "#{ENV['VIRTUAL_ENV']}/bin:#{ENV['PATH']}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"

ESCAPED_SITE_URL = node[:ckan][:site_url].gsub('/','\\/')
ESCAPED_SOLR_URL = node[:ckan][:solr_url].gsub('/','\\/')
ESCAPED_STORAGE_PATH = node[:ckan][:file_storage_dir].gsub('/','\\/')

# Create user
user node[:ckan][:user] do
  home "/home/#{node[:ckan][:user]}"
  supports :manage_home => true
end

# Create virtualenv directory
directory ENV['VIRTUAL_ENV'] do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end

# Create python virtualenv
python_virtualenv ENV['VIRTUAL_ENV'] do
  interpreter "python2.7"
  owner node[:ckan][:user]
  group node[:ckan][:user]
  options "--no-site-packages"
  action :create
end

# Create source directory
directory SOURCE_DIR do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end

# Clone CKAN into source directory
git CKAN_DIR do
  user node[:ckan][:user]
  group node[:ckan][:user]
  repository node[:repository][:url]
  reference node[:repository][:commit]
  enable_submodules true
  action :sync
end

# Install CKAN Package
python_pip CKAN_DIR do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  options "--exists-action=i -e"
  action :install
end

# Install CKAN's requirements
python_pip "#{CKAN_DIR}/requirements.txt" do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

# Create Postgres User and Database
postgresql_user node[:ckan][:sql_user] do
  superuser true
  createdb true
  login true
  password node[:ckan][:sql_password]
end
postgresql_database node[:ckan][:sql_db_name] do
  owner node[:ckan][:sql_user]
  encoding "utf8"
end

# Create config directory
directory node[:ckan][:config_dir] do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end

# Create configuration file in CKAN directory
execute "make paster's config file" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "paster make-config ckan development.ini.tmp --no-interactive"
  creates "#{CKAN_DIR}/development.ini.tmp"
end

# Copy config file to config directory
file "#{node[:ckan][:config_dir]}/development.ini" do
  content lazy { IO.read("#{CKAN_DIR}/development.ini.tmp") }
  action :create
end

# Edit configuration file
# solr_url and ckan.site_id
execute "edit configuration file to setup ckan.site_url and ckan.site_id" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  command "sed -i -e 's/^ckan.site_id.*/ckan.site_id=#{node[:ckan][:project_name]}/;s/.*ckan.site_url.*/ckan.site_url=#{ESCAPED_SITE_URL}/' development.ini"
end

# Configure database variables
execute "edit configuration file to setup database urls" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  command "sed -i -e 's/.*sqlalchemy.url.*/sqlalchemy.url=postgresql:\\/\\/#{node[:ckan][:sql_user]}:#{node[:ckan][:sql_password]}@localhost\\/#{node[:ckan][:sql_db_name]}/' development.ini"
end

# Install and configure Solr
package "solr-jetty"
template "/etc/default/jetty" do
  variables({
    :java_home => node["java"]["java_home"]
  })
end

template "/etc/default/jetty8" do
  source 'jetty.erb'
  variables({
    :java_home => node["java"]["java_home"]
  })
end

link "/etc/solr/conf/schema.xml" do
  to "#{CKAN_DIR}/ckan/config/solr/schema.xml"
  action :create
end
# Configure solr url
execute "edit configuration file to setup solr url" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  command "sed -i -e 's/.*solr_url.*/solr_url=#{ESCAPED_SOLR_URL}/' development.ini"
end
service "jetty8" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

# Create database tables
execute "create database tables" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "paster db init -c #{node[:ckan][:config_dir]}/development.ini"
end

# Link who.ini
link "#{node[:ckan][:config_dir]}/who.ini" do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  to "#{SOURCE_DIR}/ckan/ckan/config/who.ini"
  action :create
end

# Create file storage directory
directory node[:ckan][:file_storage_dir] do
  owner node[:ckan][:user]
  group node[:ckan][:user]
  recursive true
  action :create
end
# Set storage path in config file
execute "set storage path in config file" do
  user node[:ckan][:user]
  cwd node[:ckan][:config_dir]
  command "sed -i -e 's/.*ckan.storage_path.*/ckan.storage_path=#{ESCAPED_STORAGE_PATH}/' development.ini"
end

package 'npm'

execute "install less and nodewatch" do
  cwd "#{CKAN_DIR}"
  command "sudo npm install less@1.7.5 nodewatch"
end
