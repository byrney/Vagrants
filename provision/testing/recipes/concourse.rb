
include_recipe 'debian-dev-box::postgres'

remote_file '/usr/local/bin/concourse' do
    source 'https://github.com/concourse/concourse/releases/download/v2.2.1/concourse_linux_amd64' 
    owner 'root'
    mode '0755'
    action :create
end

execute 'keys' do
    command "ssh-keygen -t rsa -f host_key -N '' && ssh-keygen -t rsa -f worker_key -N '' && ssh-keygen -t rsa -f session_signing_key -N ''"
    creates 'session_signing_key'
    cwd '/home/vagrant'
end

execute 'worker_key' do
    command 'cp worker_key.pub authorized_worker_keys'
    creates 'authorized_worker_keys'
    cwd '/home/vagrant'
end


