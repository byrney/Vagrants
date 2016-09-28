# Sets up test database and tables for ckan and ckanext (optional)

TEST_SQL_DB_NAME = "#{node[:ckan][:sql_db_name]}_test"
TEST_DATASTORE_SQL_DB_NAME = "#{node[:ckan][:datastore][:sql_db_name]}_test"
ENV['VIRTUAL_ENV'] = "/usr/lib/ckan/#{node[:ckan][:project_name]}"
SOURCE_DIR = "#{ENV['VIRTUAL_ENV']}/src"
CKAN_DIR = "#{SOURCE_DIR}/ckan"

# Install dev dependencies
python_pip "#{CKAN_DIR}/dev-requirements.txt" do
  user node[:ckan][:user]
  group node[:ckan][:user]
  virtualenv ENV['VIRTUAL_ENV']
  options "-r"
  action :install
end

# Create test databases
postgresql_database "#{TEST_SQL_DB_NAME}" do
  owner node[:ckan][:sql_user]
  encoding "utf8"
end
postgresql_database "#{TEST_DATASTORE_SQL_DB_NAME}" do
  owner node[:ckan][:sql_user]
  encoding "utf8"
end
# Configure test urls
execute "edit test configuration file to setup database url" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "sed -i -e 's/.*sqlalchemy.url.*/sqlalchemy.url=postgresql:\\/\\/#{node[:ckan][:sql_user]}:#{node[:ckan][:sql_password]}@localhost\\/#{TEST_SQL_DB_NAME}/' test-core.ini"
end
execute "edit test configuration file to setup write datastore database url" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "sed -i -e 's/.*ckan.datastore.write_url.*/ckan.datastore.write_url=postgresql:\\/\\/#{node[:ckan][:sql_user]}:#{node[:ckan][:sql_password]}@localhost\\/#{TEST_DATASTORE_SQL_DB_NAME}/' test-core.ini"
end
execute "edit test configuration file to setup read datastore database url" do
  user node[:ckan][:user]
  cwd CKAN_DIR
  command "sed -i -e 's/.*ckan.datastore.read_url.*/ckan.datastore.read_url=postgresql:\\/\\/#{node[:ckan][:datastore][:sql_user]}:#{node[:ckan][:sql_password]}@localhost\\/#{TEST_DATASTORE_SQL_DB_NAME}/' test-core.ini"
end

# Set permissions on test database tables
execute "set permissions on test database tables" do
  cwd CKAN_DIR
  command "paster --plugin=ckan datastore set-permissions -c test-core.ini | sudo -u postgres psql"
end

# Best to run the tests from the command line of the provisioned machine
# itself, but uncomment this if you don't mind waiting for the tests to run.
# execute "run tests" do
#   user node[:ckan][:user]
#   cwd CKAN_DIR
#   command "nosetests --ckan --reset-db --with-pylons=test-core.ini --nologcapture ckan ckanext"
# end
