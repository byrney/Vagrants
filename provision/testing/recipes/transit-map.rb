

#
# dependencies
#
package %W(git vim unzip curl build-essential software-properties-common )

#
# osm packages + postgis
#

#
# renderd
#
package %W(apache2 libapache2-mod-tile)

git 'sync-app' do
    repository 'https://github.com/byrney/transit-map.git'
    destination "/home/vagrant/transit-map"
    user 'vagrant'
    action :checkout
end

# #
# # renderd
# #
# template '/etc/renderd.conf' do
#     source 'renderd.conf.erb'
#     mode '0755'
#     variables(:xml => '/home/vagrant/osm/openstreetmap-carto/style.xml', :host => 'localhost')
#     notifies :restart, 'service[renderd]', :immediate
# end

# service 'renderd' do
#     init_command '/etc/init.d/renderd'
#     action :start
# end

