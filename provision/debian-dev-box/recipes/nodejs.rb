apt_package 'apt-transport-https'

apt_repository 'node.js' do
  uri "https://deb.nodesource.com/node_6.x"
  distribution node['lsb']['codename']
  components ['main']
  key "https://deb.nodesource.com/gpgkey/nodesource.gpg.key"
end

apt_package 'nodejs'


