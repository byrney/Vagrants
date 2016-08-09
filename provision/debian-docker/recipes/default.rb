

#
# https://github.com/pachyderm/pachyderm/blob/master/SETUP.md
#

package 'apt-transport-https'
package 'ca-certificates'
package 'fuse'
package 'vim'

# apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
# apt-get update
apt_repository "dockerproject" do
  uri "https://apt.dockerproject.org/repo"
  distribution 'debian-jessie'
  components ["main"]
  keyserver "hkp://p80.pool.sks-keyservers.net:80"
  key "58118E89F3A912897C070ADBF76221572C52609D"
end


#
# Install docker engine
#
package 'docker-engine'

group 'docker' do
    members 'vagrant'
end

service 'docker' do
    action :start
end

#
# install golang
#
ark 'go' do
    url  'https://storage.googleapis.com/golang/go1.6.2.linux-amd64.tar.gz'
    checksum 'e40c36ae71756198478624ed1bb4ce17597b3c19d243f3f0899bb5740d56212a'
    append_env_path true
    version '1.6.2'
end

directory '/home/vagrant/gopath' do
    owner 'vagrant'
end

#
# Install kubernetes
#
remote_file '/usr/local/bin/kubectl' do
    source 'https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/linux/amd64/kubectl'
    mode '0755'
end

remote_file '/usr/local/bin/kube-apiserver' do
    source 'https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/linux/amd64/kube-apiserver'
    mode '0755'
end

#
# download pachyderm
#
execute 'goget' do
    command 'go get github.com/pachyderm/pachyderm'
    environment({'GOPATH' => '/home/vagrant/gopath'})
    creates '/home/vagrant/gopath/src/github.com/pachyderm/pachyderm'
    user 'vagrant'
end

#
# start kubernetes
#
execute 'launch-kube' do
    command 'make launch-kube'
    cwd '/home/vagrant/gopath/src/github.com/pachyderm/pachyderm'
end

#
# start packhyderm
#
execute 'launch' do
    command 'make launch'
    cwd '/home/vagrant/gopath/src/github.com/pachyderm/pachyderm'
    environment({'GOPATH' => '/home/vagrant/gopath:/usr/local/go'})
end


