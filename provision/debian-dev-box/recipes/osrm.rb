
package %W(git g++ cmake libboost-dev libboost-filesystem-dev libboost-thread-dev
libboost-system-dev libboost-regex-dev libstxxl-dev libxml2-dev libsparsehash-dev libbz2-dev
zlib1g-dev libzip-dev libgomp1 liblua5.1-0-dev
libluabind-dev pkg-config libgdal-dev libboost-program-options-dev libboost-iostreams-dev
libboost-test-dev libtbb-dev libexpat1-dev )

git 'sync-osrm' do
    repository 'https://github.com/Project-OSRM/osrm-backend.git'
    destination '/home/vagrant/osrm-backend'
    user 'vagrant'
    revision '5.5'
end


# mkdir -p build
directory '/home/vagrant/osrm-backend/build' do
    owner 'vagrant'
end

# cmake .. -DCMAKE_BUILD_TYPE=Release
execute 'cmake' do
    command 'cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_RULE_MESSAGES=OFF'
    cwd '/home/vagrant/osrm-backend/build'
    creates 'Makefile'
end

# cmake --build .
execute 'build' do
    command 'cmake --build .'
    cwd '/home/vagrant/osrm-backend/build'
end

# sudo cmake --build . --target install
execute 'install' do
    command 'cmake --build . --target install'
    cwd '/home/vagrant/osrm-backend/build'
end


#
# Follwing sections from here
#https://github.com/Project-OSRM/osrm-backend/wiki/Running-OSRM
#

#
# import map data
#
directory '/home/vagrant/devon' do
    owner 'vagrant'
end

remote_file '/home/vagrant/devon/devon-latest.osm.pbf' do
    source 'http://download.geofabrik.de/europe/great-britain-latest.osm.pbf'
    action :create
    owner 'vagrant'
    notifies :run, 'execute[extract]'
end

template '/home/vagrant/osrm-backend/devon.lua' do
    source 'osrm-profile.lua'
    notifies :run, 'execute[extract]'
end

execute 'extract' do
    command 'osrm-extract -p ../osrm-backend/profile.lua devon-latest.osm.pbf'
    creates 'devon-latest.osrm'
    cwd '/home/vagrant/devon'
    notifies :run, 'execute[contract]'
end

execute 'contract' do
    command 'osrm-contract devon-latest.osrm'
    cwd '/home/vagrant/devon'
end

link '/usr/bin/node' do
    to '/usr/bin/nodejs'
end

package 'npm'

git 'sync-frontend' do
    repository 'https://github.com/Project-OSRM/osrm-frontend'
    destination '/home/vagrant/osrm-frontend'
    user 'vagrant'
end


template '/home/vagrant/osrm-frontend/src/leaflet_options.js' do
    source 'osrm-leaflet-options.js'
end

execute 'npm-install' do
    command 'npm install'
    cwd '/home/vagrant/osrm-frontend'
    creates 'node_modules'
end


execute 'npm-build' do
    command 'npm run build'
    cwd '/home/vagrant/osrm-frontend'
    creates 'bundle.js'
end


