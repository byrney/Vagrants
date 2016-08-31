
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


package %W(libgeos-dev proj-bin osm2pgsql osmctools )

#
# renderd
#
package %W(renderd gdal-bin mapnik-utils node-carto apache2 libapache2-mod-tile)

#
# postgres instance with postgis
#
port=5452
instance='osm'

node.default['postgis']['port'] = port
node.default['postgis']['instance'] = instance

include_recipe('debian-dev-box::postgis')

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
    command 'psql -d gis -p 5452 -c "create extension hstore; create extension postgis;create extension pgrouting"'
    action :nothing
    user 'postgres'
end

# file '/home/vagrant/up.sh' do
#     content <<-EOS
#         sudo -u postgres #{bin_dir}/pg_ctl -w -l '#{log_dir}/#{instance}.log' -D #{data_dir} start &&
#         renderd -f
#     EOS
# end
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

#
# import xml map data for routing
#
remote_file '/home/vagrant/osm/devon-latest.osm.bz2' do
    source 'http://download.geofabrik.de/europe/great-britain/england/devon-latest.osm.bz2'
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

