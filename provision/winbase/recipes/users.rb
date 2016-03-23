
user=node['users']['username']

git "Users/#{user}/Config" do
    repository 'https://github.com/byrney/Config.git'
    notifies :run, 'execute[install-config]', :immediately
end


execute "install-config" do
    u = user
    h = "c:\\Users\\#{u}"
    #creates "#{h}/.vimrc"
    cwd "#{h}\\Config"
    command 'bash install.sh rob.cfg'
    environment 'HOME' => "c:\\Users\\#{u}"
    action :nothing
end
