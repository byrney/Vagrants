
case node['platform_family']
when 'debian'
    package 'apt-transport-https'
    package 'ca-certificates'

    node['lsb']['codename'] || raise("No codename. install lsb-release?")
    #
    # Postgres install
    #
    apt_repository "postgresql" do
        uri "http://apt.postgresql.org/pub/repos/apt/"
        distribution "#{node['lsb']['codename']}-pgdg"
        components ["main"]
        key "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
    end


    package 'postgresql-9.5'

when 'rhel'

    remote_file '/home/vagrant/pgdg-centos95-9.5-2.noarch.rpm' do
        owner 'vagrant'
        action :create
        source 'https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm' 
    end

    rpm_package 'pgdg-repo-rpm' do
        source '/home/vagrant/pgdg-centos95-9.5-2.noarch.rpm'
        action :install
    end

    package 'postgresql95-server'
    package 'postgresql95-contrib'

    execute 'setup' do
        command '/usr/pgsql-9.5/bin/postgresql95-setup initdb' 
        creates '/var/lib/pgsql/9.5/data/PG_VERSION'
    end

    service 'postgresql-9.5.service' do
        action [:enable, :start]
    end

end
