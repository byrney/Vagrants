
package 'apt-transport-https'
package 'ca-certificates'

#
# Postgres 9.5 install from PDG
#
include_recipe "#{cookbook_name}::postgres"

#
# pglogical extension from 2nd quadrant
#
apt_repository "2ndquadrant" do
  uri "http://packages.2ndquadrant.com/pglogical/apt/"
  distribution "#{node['lsb']['codename']}-2ndquadrant"
  components ["main"]
  key "http://packages.2ndquadrant.com/pglogical/apt/AA7A6805.asc"
end

package 'postgresql-9.5-pglogical'

NODES = {'subs' => 5433, 'main' => 5432}

#
# Create subscriber node. main is created by the install
#
execute 'create-cluster-subs' do
    command "pg_createcluster -p #{NODES['subs']} 9.5 subs"
    creates '/etc/postgresql/9.5/subs'
end


['subs', 'main'].each do |instance|

    conf_dir = "/etc/postgresql/9.5/#{instance}"

    execute "stop-cluster-#{instance}" do
        command "pg_ctlcluster 9.5 #{instance} stop"
        only_if "pg_ctlcluster 9.5 #{instance} status"
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
        variables(:port => NODES[instance], :instance => instance)
    end

    execute "start-cluster-#{instance}" do
        command "pg_ctlcluster 9.5 #{instance} start"
    end

    execute "create-user-#{instance}" do
        command "createuser -U postgres -p #{NODES[instance]} -s $(whoami)"
        not_if  %Q(psql -U postgres -p #{NODES[instance]} -tAc "select 1 from pg_roles where rolname='$(whoami)'" | grep 1)
        user    "vagrant"
    end

    execute "create-db-#{instance}" do
        command "createdb -U postgres -p #{NODES[instance]} $(whoami)"
        not_if  %Q(psql -U postgres -p #{NODES[instance]} -tAc "select 1 from pg_database where datname='$(whoami)'"| grep 1)
        user    "vagrant"
    end

    execute "setup-#{instance}" do
        command "psql -p #{NODES[instance]} --pset pager=off --set ON_ERROR_STOP=1 --set VERBOSITY=terse -f /home/vagrant/#{instance}.sql"
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

template "/home/vagrant/main.sql" do
    source   "master.sql"
    owner    "vagrant"
    #notifies :run, 'execute[setup-main]', :immediate
end

template "/home/vagrant/subs.sql" do
    source   "subscriber.sql"
    owner    "vagrant"
    #notifies :run, 'execute[setup-subs]', :immediate
end


####  still plenty to do here
## http://2ndquadrant.com/en-us/resources/pglogical/pglogical-docs/

