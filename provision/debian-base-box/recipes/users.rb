
username = node['users']['username'] || raise('no username in chef.json. aborting')
priv_key = node['users']['priv_key'] || nil
pub_key  = node['users']['pub_key']  || nil
home_dir = "/home/#{username}"

package 'git'

user username do
    shell '/bin/bash'
    password '12345'
    manage_home true
    home "/home/#{username}"
end

#
# if no keys specified in chef.json then create some
#
execute "keygen-#{username}" do
    creates "#{home_dir}/.ssh/id_rsa"
    command "ssh-keygen -q -f #{home_dir}/.ssh/id_rsa -P '' "
    user username
    not_if { priv_key || pub_key }
end

#
# if keys provided in chef.json install them
#
directory "#{home_dir}/.ssh" do
    owner username
    action :create
    mode '0755'
end

file "#{home_dir}/.ssh/id_rsa.pub" do
    content pub_key
    mode '0644'
    owner username
    only_if { pub_key }
end

file "#{home_dir}/.ssh/id_rsa" do
    content priv_key
    mode '0600'
    owner username
    sensitive true
    only_if { priv_key }
end

# if a /vagrant dir is mounted from the host
# add any public keys found to the auth keys file of the user
execute "key-import-#{username}" do
    creates "#{home_dir}/.ssh/authorized_keys"
    command "cat /vagrant/*.pub >> #{home_dir}/.ssh/authorized_keys"
    user username
    only_if "test -f '/vagrant/#{username}.pub' "
end

file "#{home_dir}/.ssh/config" do
    content "Host bitbucket.org\n\tStrictHostKeyChecking no\n"
    mode '0600'
    owner username
end

git 'sync-config' do
    repository 'git@bitbucket.org:rpbyrne/config.git'
    destination "#{home_dir}/Config"
    user username
    notifies :run, 'execute[install-config]', :immediately
end

execute "install-config" do
    creates "#{home_dir}/.vim"
    user username
    cwd "#{home_dir}/Config"
    command 'bash install.sh rob.cfg'
    environment 'HOME' => "#{home_dir}"
    action :nothing
end

