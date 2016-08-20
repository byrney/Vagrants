
execute "tz-refresh" do
    command "dpkg-reconfigure -f noninteractive tzdata"
    action :nothing
end
file "/etc/timezone" do
    content "Europe/London\n"
    action  :create
    notifies :run, 'execute[tz-refresh]', :immediate
end
execute "apt-update" do
    creates '/tmp/apt-update.done'
    command "apt-get update > /tmp/apt-update.done"
end
BASE_PACKAGES = %w(git vim tmux zip silversearcher-ag )
APP_PACKAGES  = %w(xorg openbox tint2)

BASE_PACKAGES.each {|p| package p }
APP_PACKAGES.each  {|p| package p }

file "/etc/xdg/openbox/autostart" do
    content "tint2 &\n"
    action  :create
end

['rob'].each do |u|
    user u do
        shell '/bin/bash'
        password '12345'
        manage_home true
        home "/home/#{u}"
    end

    execute "keygen-#{u}" do
        creates "/home/#{u}/.ssh/id_rsa"
        command "ssh-keygen -q -f /home/#{u}/.ssh/id_rsa -P '' "
        user u
    end
    execute "key-import-#{u}" do
        creates "/home/#{u}/.ssh/authorized_keys"
        command "cat /vagrant/*.pub >> /home/#{u}/.ssh/authorized_keys"
        user u
        only_if "test -f '/vagrant/#{u}.pub' "
    end
end

git 'Config' do
    repository 'https://github.com/byrney/Config.git'
    destination '/home/rob/Config'
    user 'rob'
end
execute "install-config" do
    creates "/home/rob/.vim"
    user 'rob'
    cwd '/home/rob/Config'
    command 'bash install.sh rob.cfg'
    environment 'HOME' => '/home/rob'
end
