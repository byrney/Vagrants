
port=5432

include_recipe 'debian-dev-box::postgres'

remote_file '/usr/local/bin/concourse' do
    source 'https://github.com/concourse/concourse/releases/download/v2.2.1/concourse_linux_amd64' 
    owner 'root'
    mode '0755'
    action :create
end

remote_file '/usr/local/bin/fly' do
    source'http://localhost:8080/api/v1/cli?arch=amd64&platform=linux'
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

execute "create-user" do
    command "createuser -U postgres -p #{port} -s $(whoami)"
    not_if  %Q(psql -U postgres -p #{port} -tAc "select 1 from pg_roles where rolname='$(whoami)'" | grep 1)
    user    "postgres"
end

execute "create-db" do
    command "createdb -U postgres -p #{port} atc"
    not_if  %Q(psql -U postgres -p #{port} -tAc "select 1 from pg_database where datname='atc'"| grep 1)
    user    "postgres"
end

