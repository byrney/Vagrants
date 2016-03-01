
# apt-get install apt-transport-https ca-certificates
package 'apt-transport-https'
package 'ca-certificates'

# apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
# apt-get update
apt_repository "dockerproject" do
  uri "https://apt.dockerproject.org/repo"
  distribution 'debian-jessie'
  components ["main"]
  keyserver "hkp://p80.pool.sks-keyservers.net:80"
  key " 58118E89F3A912897C070ADBF76221572C52609D"
end

# apt-get install docker-engine
package 'docker-engine'

# groupadd docker
# sudo gpasswd -a ${USER} docker
group 'docker' do 
    members 'vagrant'
end

# sudo service docker restart
service 'docker' do
    action :start
end

