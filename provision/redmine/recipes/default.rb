
apt_update 'apt-update' do
  frequency 86400
  action :periodic
end

package 'ca-certificates'
package 'libssl-dev'
package %w( postgresql apache2 libapache2-mod-passenger debconf-utils)


DPKG_SEEDS='
redmine redmine/instances/default/dbconfig-install      boolean true
redmine redmine/instances/default/dbconfig-upgrade      boolean true
redmine redmine/instances/default/database-type select  pgsql
redmine redmine/instances/default/pgsql/app-pass        password hahaha
redmine redmine/instances/default/password-confirm      password hahaha
'

# set config before redmine package install to prevent it from prompting
execute 'dpkg-seed-redmine' do
    command "echo \"#{DPKG_SEEDS}\" | debconf-set-selections"
end

execute 'redmine-pgsql' do
    # adjust path so that the post install script doesn't get chef's version of ruby
    command 'apt-get install -q -y redmine-pgsql'
    creates '/usr/share/redmine'
    environment ({'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'})
end

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

execute 'circle-theme' do
    command 'unzip /vagrant/circle_theme-2_1_2.zip -d /usr/share/redmine/public/themes'
    cwd '/usr/share/redmine'
    creates '/usr/share/redmine/public/themes/circle'
end

directory '/usr/share/redmine/plugins'

execute 'crm-plugin' do
    command 'unzip /vagrant/redmine_crm-4_1_1-light.zip -d /usr/share/redmine/plugins'
    cwd '/usr/share/redmine'
    creates '/usr/share/redmine/plugins/redmine_crm'
    notifies :run, 'execute[bundle-install]', :immediately
    notifies :run, 'execute[agile-rake]', :immediately
    action :nothing
end

execute 'agile-plugin' do
    command 'unzip /vagrant/redmine_agile-1_4_4-light.zip -d /usr/share/redmine/plugins'
    cwd '/usr/share/redmine'
    creates '/usr/share/redmine/plugins/redmine_agile'
    notifies :run, 'execute[bundle-install]', :immediately
end

execute 'bundle-install' do
    command '/usr/bin/bundle install --without development test --no-deployment && chmod a+rwx /var/lib/redmine/Gemfile.lock'
    cwd '/usr/share/redmine'
    notifies :restart, 'service[apache2]', :delayed
end

execute 'crm-rake' do
    command '/usr/bin/bundle exec /usr/bin/rake redmine:plugins NAME=redmine_contacts RAILS_ENV=production'
    cwd '/usr/share/redmine'
    action :nothing
end

execute 'agile-rake' do
    command '/usr/bin/bundle exec /usr/bin/rake redmine:plugins NAME=redmine_agile RAILS_ENV=production'
    cwd '/usr/share/redmine'
    action :nothing
end

