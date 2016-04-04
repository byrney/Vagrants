
package 'apt-transport-https'
package 'ca-certificates'

#
# Postgres 9.5 install from PDG
#
include_recipe "#{cookbook_name}::postgres"

apt_repository "2ndquadrant" do
  uri "http://packages.2ndquadrant.com/pglogical/apt/"
  distribution 'jessie-2ndquadrant'
  components ["main"]
  key "http://packages.2ndquadrant.com/pglogical/apt/AA7A6805.asc"
end

package 'postgresql-9.5-pglogical'

NODES = {'subs' => 5433, 'main' => 5432}

execute 'create-cluster-subs' do
    command "pg_createcluster -p NODES['subs'] 9.5 subs"
    creates '/etc/postgresql/9.5/subs'
end


['subs', 'main'].each do |instance|

    conf_dir = "#{conf_dir}/g"

    execute "stop-cluster-#{instance}" do
        command "pg_ctlcluster 9.5 #{instance} stop"
        only_if "pg_ctlcluster 9.5 #{instance} status"
    end

    template "#{conf_dir}/pg_hba.conf" do
        source 'pg_hba.conf'
        owner 'postgres'
        group 'postgres'
        mode '0755'
    end

    template "#{conf_dir}/postgresql.conf" do
        source 'postgresql.conf'
        variables(:port => NODES[instance], :instance => instance)
        owner 'postgres'
        group 'postgres'
        mode '0755'
    end

    execute "start-cluster-#{instance}" do
        command "pg_ctlcluster 9.5 #{instance} start"
    end

    execute "create-user-#{instance}" do
        command "createuser -U postgres -p #{NODES[instance]} -s pgltest"
        not_if %Q(psql -U postgres -p #{NODES[instance]} -tAc "select 1 from pg_roles where rolname='pgltest'" | grep 1)
    end

    execute "create-db-#{instance}" do
        command "createdb -U postgres -p #{NODES[instance]} pgltest"
        not_if %Q(psql -U postgres -p #{NODES[instance]} -tAc "select 1 from pg_database where datname='pgltest'"| grep 1)
    end

end

####  still plenty to do here
## http://2ndquadrant.com/en-us/resources/pglogical/pglogical-docs/

