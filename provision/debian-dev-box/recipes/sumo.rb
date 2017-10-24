
include_recipe('debian-base-box::default')
include_recipe('debian-base-box::apps')
include_recipe('debian-base-box::xorg')

package %W(libxerces-c3.1 libxerces-c-dev libgdal1h libgdal-dev)
package %W(libfox-1.6-dev libgl1-mesa-dev libglu1-mesa-dev)


remote_file '/home/vagrant/sumo-src.tgz' do
    source 'http://prdownloads.sourceforge.net/sumo/sumo-src-0.31.0.tar.gz?download'
    action :create_if_missing
    owner 'vagrant'
end

execute 'untar' do
    cwd '/home/vagrant'
    command 'tar zxf sumo-src.tgz'
    user 'vagrant'
    creates 'sumo-0.31.0'
    notifies :run, 'execute[configure]'
    user 'vagrant'
end

execute 'configure' do
    cwd '/home/vagrant/sumo-0.31.0'
    command './configure'
    creates 'Makefile'
    notifies :run, 'execute[build]'
    action :nothing
    user 'vagrant'
end

execute 'build' do
    cwd '/home/vagrant/sumo-0.31.0'
    command 'make'
    action :nothing
    user 'vagrant'
end

execute 'install' do
    cwd '/home/vagrant/sumo-0.31.0'
    command 'make install'
end
