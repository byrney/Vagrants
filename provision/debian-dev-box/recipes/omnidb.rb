

package ['python-pip']

#
# rstudio install
#
remote_file '/home/vagrant/omnidb.deb' do
    source 'https://omnidb.org/dist/2.0.4/omnidb-server_2.0.4-debian-amd64.deb'
    owner 'vagrant'
    group 'vagrant'
    action :create
    #checksum '98ea59d3db00e0083d3e4053514f764d'
end

dpkg_package 'omnidb.deb' do
    source "/home/vagrant/omnidb.deb"
end
