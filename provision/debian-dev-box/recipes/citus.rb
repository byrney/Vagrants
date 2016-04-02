
package 'apt-transport-https'
package 'ca-certificates'

#
# Postgres install
#
apt_repository "postgresql" do
  uri "http://apt.postgresql.org/pub/repos/apt/"
  distribution 'jessie-pgdg'
  components ["main"]
  key "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
end

package 'postgresql-9.5'

#
# citus install
#
remote_file '/home/vagrant/citus5.deb' do
    source 'https://s3.amazonaws.com/packages.citusdata.com/debian/jessie/postgresql-9.5-citus_5.0.0-1_amd64.deb'
    owner 'vagrant'
    group 'vagrant'
    action :create
end

dpkg_package 'citus5.deb' do
    source "/home/vagrant/citus5.deb"
end


#
# create citus instances
#
Instance = Struct.new(:name, :port)
instances = node['citus']['instances'].map {|h| Instance.new(h['name'], Integer(h['port'])) }
workers = node['citus']['workers'].map {|h| "#{h['ip']} #{h['port']}" }
instances.each do |i|

    conf_dir = "/etc/postgresql/9.5/#{i.name}"
    data_dir = "/var/lib/postgresql/9.5/#{i.name}"

    # stop the cluster if running
    execute "stop-citus-#{i.name}" do
        command %Q( pg_ctlcluster 9.5 #{i.name} stop -- -w )
        only_if  "pg_ctlcluster 9.5 #{i.name} status"
    end

    # Create the cluster and modify main pgconf to include local settings
    bash "setup-citus-#{i.name}" do
        code <<-EOH
            [[ -d #{conf_dir} ]] || pg_createcluster 9.5 #{i.name}
            grep -q local.conf #{conf_dir}/postgresql.conf || echo "include 'local.conf'"  >> #{conf_dir}/postgresql.conf
            EOH
    end

    # generate local settings (preload libs, listen address etc)
    template "#{conf_dir}/local.conf" do
        source 'pg_local.conf'
        owner 'postgres'
        variables(:port => i.port)
        group 'postgres'
        mode '0755'
    end

    # add worker list  (only required on master but we do it everywhere)
    file "#{data_dir}/pg_worker_list.conf" do
        content workers.join("\n")
        owner 'postgres'
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
        command %Q( pg_ctlcluster 9.5 #{i.name} start )
        not_if  "pg_ctlcluster 9.5 #{i.name} status"
    end

    # create the database
    execute "createdb-citus-#{i.name}" do
        user    "vagrant"
        command "createdb -U postgres -p #{i.port} $(whoami)"
        not_if  %Q( psql -tA -p #{i.port} -U postgres -d postgres -c "select 1 from pg_database where datname='$(whoami)'"| grep 1 )
    end

    # create the user
    execute "create-user-#{i.name}" do
        user 'postgres'
        command "createuser -U postgres -p #{i.port} -s vagrant"
        not_if %Q(psql -p #{i.port} -U postgres -tAc "select 1 from pg_roles where rolname='vagrant'" | grep 1)
    end

    # load the citus extension into the database
    execute "extension-citus-#{i.name}" do
        user "vagrant"
        command <<-EOH
            psql -p #{i.port} -c "create extension citus"
        EOH
        not_if %Q(psql -tA -p #{i.port} -c "select 1 from pg_extension where extname='citus'"| grep 1 )
    end

end

