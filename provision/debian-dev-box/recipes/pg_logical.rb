
package 'apt-transport-https' if node['platform_family'] == 'debian'
package 'ca-certificates'

#
# Postgres 9.5 install from PDG
#
include_recipe "#{cookbook_name}::postgres"

#
# pglogical extension from 2nd quadrant
#
case(node['platform_family'])
when 'debian'

    apt_repository "2ndquadrant" do
        uri "http://packages.2ndquadrant.com/pglogical/apt/"
        distribution "#{node['lsb']['codename']}-2ndquadrant"
        components ["main"]
        key "http://packages.2ndquadrant.com/pglogical/apt/AA7A6805.asc"
    end
    package 'postgresql-9.5-pglogical'

when 'rhel'

    remote_file '/home/vagrant/pglogical-rhel-1.0-2.noarch.rpm' do
        source 'http://packages.2ndquadrant.com/pglogical/yum-repo-rpms/pglogical-rhel-1.0-2.noarch.rpm'
        owner 'vagrant'
    end

    rpm_package '2ndQ-repo-rpm' do
        source '/home/vagrant/pglogical-rhel-1.0-2.noarch.rpm'
        action :install
    end
    package 'postgresql95-pglogical'

end

#
# Configure 2 nodes leader and follower on 5432 and 5433
# resp
#
NODES = {'follow' => 5443, 'lead' => 5442}
NODES.each_pair do |instance, port|

    case(node['platform_family'])
    when 'debian'
        conf_dir = "/var/lib/postgresql/9.5/#{instance}"
        data_dir = "/var/lib/postgresql/9.5/#{instance}"
        log_dir = "/var/log/postgresql/#{instance}"
        run_dir = "/var/run/postgresql/#{instance}"
        bin_dir = "/usr/lib/postgresql/9.5/bin"
    when 'rhel'
        conf_dir = "/var/lib/pgsql/9.5/#{instance}"
        data_dir = "/var/lib/pgsql/9.5/#{instance}"
        log_dir = "/var/log/postgresql"
        run_dir = "/var/run/postgresql/#{instance}"
        bin_dir = "/usr/pgsql-9.5/bin"
    end

    execute "stop-cluster-#{instance}" do
        command "#{bin_dir}/pg_ctl -D '#{data_dir}' -w stop"
        only_if "#{bin_dir}/pg_ctl -D '#{data_dir}' status"
        user 'postgres'
    end

    execute "initdb-#{instance}" do
        command "#{bin_dir}/initdb -D '#{data_dir}'"
        creates "#{data_dir}/postgresql.conf"
        user 'postgres'
    end

    template "#{conf_dir}/pg_hba.conf" do
        source 'pg_hba.conf'
        owner  'postgres'
        group  'postgres'
        mode   '0755'
    end

    template "#{conf_dir}/postgresql.conf" do
        source 'postgresql.conf'
        owner  'postgres'
        group  'postgres'
        mode   '0755'
        variables(:port => port, :instance => instance, :conf_dir => conf_dir, :data_dir => data_dir)
    end

    directory run_dir do
        owner 'postgres'
        group 'postgres'
    end

    directory log_dir do
        owner 'postgres'
        group 'postgres'
    end

    execute "start-cluster-#{instance}" do
        command "#{bin_dir}/pg_ctl -w -l '#{log_dir}/#{instance}.log' -D #{data_dir} start"
        not_if "#{bin_dir}/pg_isready -p #{port}"
        user 'postgres'
    end

    execute "create-user-#{instance}" do
        command "createuser -U postgres -p #{port} -s $(whoami)"
        not_if  %Q(psql -U postgres -p #{port} -tAc "select 1 from pg_roles where rolname='$(whoami)'" | grep 1)
        user    "vagrant"
    end

    execute "create-db-#{instance}" do
        command "createdb -U postgres -p #{port} $(whoami)"
        not_if  %Q(psql -U postgres -p #{port} -tAc "select 1 from pg_database where datname='$(whoami)'"| grep 1)
        user    "vagrant"
    end

    execute "setup-#{instance}" do
        command "psql -p #{port} --pset pager=off --set ON_ERROR_STOP=1 --set VERBOSITY=terse -f /home/vagrant/#{instance}.sql"
        action  :nothing
        user    'vagrant'
    end

end

file "/home/vagrant/schema.sql" do
    content "drop table if exists a; create table A ( banana int, saveloy text, primary key(banana) );"
    owner   'postgres'
    group   'postgres'
    mode    '0755'
end

template "/home/vagrant/lead.sql" do
    source   "master.sql"
    owner    "vagrant"
    notifies :run, 'execute[setup-lead]', :immediate
end

template "/home/vagrant/follow.sql" do
    source   "subscriber.sql"
    owner    "vagrant"
    notifies :run, 'execute[setup-follow]', :immediate
end


