
case node['platform_family']
when 'debian'
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
when 'rhel'

    execute 'yum-update' do
        creates '/tmp/yum-update.done'
        command "yum check-update > /tmp/yum-update.done"
    end

end
