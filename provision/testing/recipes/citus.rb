
package 'apt-transport-https'
package 'ca-certificates'

#
# citus install
#

remote_file '/home/vagrant/citus-ppa.sh' do
    action :create_if_missing
    source 'https://install.citusdata.com/community/deb.sh'
    notifies :run, 'execute[citus-repo]', :immediate
end

execute 'citus-repo' do
    command 'bash /home/vagrant/citus-ppa.sh'
    action :nothing
    notifies :install, 'package[postgresql-9.6-citus-7.0]', :immediate
end

package 'postgresql-9.6-citus-7.0' do
    action :nothing
end



# create citus instances
BIN='/usr/lib/postgresql/9.6/bin'
PGCTL=File.join(BIN, 'pg_ctl')
INITDB=File.join(BIN, 'initdb')
CREATEDB=File.join(BIN, 'createdb')
PSQL=File.join(BIN, 'psql')
CREATEUSER=File.join(BIN, 'createuser')
Instance = Struct.new(:name, :port)
instances = node['citus']['instances'].map {|h| Instance.new(h['name'], Integer(h['port'])) }
workers = node['citus']['workers'].map {|h| "#{h['ip']} #{h['port']}" }
regsql =  node['citus']['workers'].map {|h| "select * from master_add_node('#{h['ip']}', #{h['port']})" }
instances.each do |i|

    conf_dir = "/var/citus/#{i.name}"
    data_dir = "/var/citus/#{i.name}"

    directory '/var/citus' do
        owner 'postgres'
        recursive true
    end

    # stop the cluster if running
    execute "stop-citus-#{i.name}" do
        command %Q( #{PGCTL} -D #{conf_dir} stop -w )
        only_if  "#{PGCTL} -D #{conf_dir} status"
        user 'postgres'
    end

    # Create the cluster and modify main pgconf to include local settings
    bash "setup-citus-#{i.name}" do
        code <<-EOH
             [[ -d #{conf_dir} ]] || #{INITDB} -D #{conf_dir}
             grep -q local.conf #{conf_dir}/postgresql.conf || echo "include 'local.conf'"  >> #{conf_dir}/postgresql.conf
        EOH
        user 'postgres'
    end

    # generate local settings (preload libs, listen address etc)
    template "#{conf_dir}/local.conf" do
        source 'pg_local.conf'
        owner 'postgres'
        variables(:port => i.port)
        group 'postgres'
        mode '0755'
    end

    # Open up trust access for the whole network
    template "#{conf_dir}/pg_hba.conf" do
        source 'pg_hba.conf'
        owner 'postgres'
        group 'postgres'
        mode '0755'
    end

    # restart the cluster
    execute "start-citus-#{i.name}" do
        command %Q( #{PGCTL} -D #{conf_dir} start -w)
        not_if  "#{PGCTL} -D #{conf_dir} status"
        user 'postgres'
    end

    # create the database
    execute "createdb-citus-#{i.name}" do
        user    "vagrant"
        command "#{CREATEDB} -U postgres -p #{i.port} $(whoami)"
        not_if  %Q( #{PSQL} -tA -p #{i.port} -U postgres -d postgres -c "select 1 from pg_database where datname='$(whoami)'"| grep 1 )
    end

    # create the user
    execute "create-user-#{i.name}" do
        user 'postgres'
        command "#{CREATEUSER} -U postgres -p #{i.port} -s vagrant"
        not_if %Q(#{PSQL} -p #{i.port} -U postgres -tAc "select 1 from pg_roles where rolname='vagrant'" | grep 1)
    end

    # load the citus extension into the database
    execute "extension-citus-#{i.name}" do
        user "vagrant"
        command <<-EOH
             #{PSQL} -p #{i.port} -c "create extension citus"
        EOH
        not_if %Q(#{PSQL} -tA -p #{i.port} -c "select 1 from pg_extension where extname='citus'"| grep 1 )
    end

    # add worker list  (only required on master but we do it everywhere)
    execute "citus-workers-#{i.name}" do
        user "vagrant"
        command <<-EOH
        #{PSQL} -p #{i.port} -c "#{regsql.join(';')}"
        EOH
    end

end

