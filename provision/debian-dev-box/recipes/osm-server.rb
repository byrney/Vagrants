
#
# dependencies
#
package %W(git vim unzip curl build-essential software-properties-common )

#
# osm packages + postgis
#

apt_repository "openstreetmap" do
    uri "http://ppa.launchpad.net/kakrueger/openstreetmap/ubuntu"
    distribution "trusty"
    components ["main"]
    trusted true
end


package %W(postgresql-9.5-postgis-2.2 libgeos-dev proj-bin osm2pgsql osmctools)

#
# renderd
#
package %W(renderd gdal-bin mapnik-utils node-carto apache2 libapache2-mod-tile)

#
# postgres instance with postgis
#
port=5452
instance='osm'

case(node['platform_family'])
when 'debian'
    conf_dir = "/var/lib/postgresql/9.5/#{instance}"
    data_dir = "/var/lib/postgresql/9.5/#{instance}"
    log_dir = "/var/log/postgresql/#{instance}"
    run_dir = "/var/run/postgresql/#{instance}"
    bin_dir = "/usr/lib/postgresql/9.5/bin"
when 'rhel'
    conf_dir = "/var/lib/pgsql/9.5/#{instance}"
    data_dir = "/var/lib/pgsql/9.5/#{instance}"
    log_dir = "/var/log/postgresql"
    run_dir = "/var/run/postgresql/#{instance}"
    bin_dir = "/usr/pgsql-9.5/bin"
end

apt_repository "pgrouting" do
    uri "http://ppa.launchpad.net/georepublic/pgrouting-unstable/ubuntu"
    distribution "trusty"
    components ["main"]
    trusted true
end

#
# overcommit
#
file '/etc/sysctl.d/60-overcommit.conf' do
    content 'vm.overcommit_memory=1'
    notifies :run, 'execute[sysctl]', :immediate
end

execute 'sysctl' do
    command 'sysctl -p /etc/sysctl.d/60-overcommit.conf'
    action :nothing
end


#
# create cluster
#
execute "stop-cluster-#{instance}" do
    command "#{bin_dir}/pg_ctl -D '#{data_dir}' -w stop"
    only_if "#{bin_dir}/pg_ctl -D '#{data_dir}' status"
    user 'postgres'
end

execute "initdb-#{instance}" do
    command "#{bin_dir}/initdb -D '#{data_dir}'"
    creates "#{data_dir}/postgresql.conf"
    user 'postgres'
end

template "#{conf_dir}/pg_hba.conf" do
    source 'pg_hba.conf'
    owner  'postgres'
    group  'postgres'
    mode   '0755'
end

template "#{conf_dir}/local.conf" do
    source 'local-gis.conf'
    owner  'postgres'
    group  'postgres'
    mode   '0755'
end

template "#{conf_dir}/postgresql.conf" do
    source 'postgresql-gis.conf'
    owner  'postgres'
    group  'postgres'
    mode   '0755'
    variables(:port => port, :instance => instance, :conf_dir => conf_dir, :data_dir => data_dir)
end

directory run_dir do
    owner 'postgres'
    group 'postgres'
end

directory log_dir do
    owner 'postgres'
    group 'postgres'
end

execute "start-cluster-#{instance}" do
    command "#{bin_dir}/pg_ctl -w -l '#{log_dir}/#{instance}.log' -D #{data_dir} start"
    not_if "#{bin_dir}/pg_isready -p #{port}"
    user 'postgres'
end

#
# setup database
#
execute "create-user" do
    command "createuser -U postgres -p #{port} -s $(whoami)"
    not_if  %Q(psql -U postgres -p #{port} -tAc "select 1 from pg_roles where rolname='$(whoami)'" | grep 1)
    user    "vagrant"
end

execute "create-www-user" do
    command "createuser -U postgres -p #{port} www-data"
    not_if  %Q(psql -U postgres -p #{port} -tAc "select 1 from pg_roles where rolname='www-data'" | grep 1)
    user    "postgres"
end

execute "create-db" do
    command "createdb -U postgres -p #{port} gis"
    not_if  %Q(psql -U postgres -p #{port} -tAc "select 1 from pg_database where datname='gis'"| grep 1)
    user    "vagrant"
    notifies :run, 'execute[extensions]', :immediate
end

execute "extensions" do
    command 'psql -d gis -p 5452 -c "create extension hstore; create extension postgis;"'
    action :nothing
    user 'postgres'
end

file '/home/vagrant/up.sh' do
    content <<-EOS
        sudo -u postgres #{bin_dir}/pg_ctl -w -l '#{log_dir}/#{instance}.log' -D #{data_dir} start &&
        renderd -f
    EOS
end
#
# create styles
#
directory '/home/vagrant/osm' do
    owner 'vagrant'
end

git 'sync-styles' do
    repository 'https://github.com/gravitystorm/openstreetmap-carto.git'
    destination "/home/vagrant/osm/openstreetmap-carto"
    user 'vagrant'
    action :checkout
end

execute 'adjust-mml-db' do
    cwd '/home/vagrant/osm/openstreetmap-carto'
    command %Q[ sed 's/"dbname": "gis"/"dbname": "gis","host": "localhost","port": 5452/g' project.mml > project-5452.mml].gsub('"', '\"')
    creates 'project-5452.mml'
    user 'vagrant'
end

execute 'create-styles' do
    command './get-shapefiles.sh && carto project-5452.mml > style.xml'
    cwd '/home/vagrant/osm/openstreetmap-carto'
    user 'vagrant'
    creates 'style.xml'
end

#
# import map data
#
remote_file '/home/vagrant/osm/devon-latest.osm.pbf' do
    source 'http://download.geofabrik.de/europe/great-britain/england/devon-latest.osm.pbf'
    action :create_if_missing
    owner 'vagrant'
end

execute 'load-devon' do
    command "osm2pgsql --create --slim --cache 1000 --number-processes 2 --hstore \
        --style /home/vagrant/osm/openstreetmap-carto/openstreetmap-carto.style --multi-geometry \
        -d gis -P #{port} /home/vagrant/osm/devon-latest.osm.pbf && touch /home/vagrant/osm/devon.log"
    creates '/home/vagrant/osm/devon.log'
    user 'vagrant'
end

#
# renderd
#
template '/etc/renderd.conf' do
    source 'renderd.conf.erb'
    mode '0755'
    variables(:xml => '/home/vagrant/osm/openstreetmap-carto/style.xml', :host => 'localhost')
    notifies :restart, 'service[renderd]', :immediate
end

service 'renderd' do
    init_command '/etc/init.d/renderd'
    action :start
end

