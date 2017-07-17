
apt_update

package 'ca-certificates'
package 'libssl-dev'
package %w( postgresql apache2 libapache2-mod-passenger debconf-utils)


DPKG_SEEDS='
redmine redmine/instances/default/dbconfig-install      boolean true
redmine redmine/instances/default/dbconfig-upgrade      boolean true
redmine redmine/instances/default/database-type select  pgsql
'

# set config before redmine package install to prevent it from prompting
execute 'dpkg-seed-redmine' do
    command "echo \"#{DPKG_SEEDS}\" | debconf-set-selections"
end

package 'redmine-pgsql'

template '/etc/apache2/sites-available/redmine.conf' do
    source 'apache-redmine.conf'
    owner 'root'
    group 'root'
end

package 'vim'

execute 'enable-passenger' do
    command 'a2enmod passenger'
    creates '/etc/apache2/mods-enabled/passenger.conf'
    notifies :restart, 'service[apache2]', :delayed
end

execute 'enable-redmine' do
    command 'a2ensite redmine.conf'
    creates '/etc/apache2/sites-enabled/redmine.conf'
    notifies :restart, 'service[apache2]', :delayed
end

execute 'disable-default-site' do
    command 'a2dissite 000-default'
    only_if { File.exists?('/etc/apache2/sites-enabled/000-default.conf') }
    notifies :restart, 'service[apache2]', :delayed
end

directory '/var/lib/redmine' do
    owner 'www-data'
    mode '0777'
    action :create
end

service 'apache2' do
    action :nothing
end
