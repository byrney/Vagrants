
include_recipe('debian-dev-box::postgres')

package %W(postgresql-9.5-postgis-2.2 postgresql-9.5-pgrouting-doc postgresql-9.5-pgrouting )

#
# postgres instance with postgis
#
port     = node['postgis']['port']
instance = node['postgis']['instance']

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

#
# overcommit
#
file '/etc/sysctl.d/60-overcommit.conf' do
    content 'vm.overcommit_memory=1'
    notifies :run, 'execute[sysctl]', :immediate
end

execute 'sysctl' do
    command 'sysctl -p /etc/sysctl.d/60-overcommit.conf'
    action :nothing
end


#
# create cluster
#
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

template "#{conf_dir}/local.conf" do
    source 'local-gis.conf'
    owner  'postgres'
    group  'postgres'
    mode   '0755'
end

template "#{conf_dir}/postgresql.conf" do
    source 'postgresql-gis.conf'
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

