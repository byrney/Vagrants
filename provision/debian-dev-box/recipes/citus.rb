
package 'apt-transport-https'
package 'ca-certificates'


# download the tarball from 2nd quadrant and expand into ~pgxl
ark "tr-citus" do
    url "https://s3.amazonaws.com/packages.citusdata.com/tutorials/try-citus-4.tar.gz"
    path "/home/vagrant/"
    action [:put]
    owner 'vagrant'
end


Instance = Struct.new(:name, :port)
instances = [Instance.new('master', 9700), Instance.new('worker', 9701)]

instances.each do |i|
    bash "setup-citus-#{i.name}" do
        cwd  "/home/vagrant/tr-citus"
        user "vagrant"
        code <<-EOH
            [[ -d data/#{i.name} ]] || bin/initdb -D data/#{i.name}
            [[ -f data/#{i.name}/pg_worker_list.conf ]] || echo "localhost 9701" > data/#{i.name}/pg_worker_list.conf
            grep -q citus data/#{i.name}/postgresql.conf || echo "shared_preload_libraries = 'citus'" >> data/#{i.name}/postgresql.conf
        EOH
    end

    execute "start-citus-#{i.name}" do
        cwd     "/home/vagrant/tr-citus"
        user    "vagrant"
        command %Q( bin/pg_ctl -w -D data/#{i.name} -o "-p #{i.port}" -l #{i.name}_logfile start )
        not_if  "bin/pg_ctl -D data/#{i.name} status"
    end

    execute "createdb-citus-#{i.name}" do
        cwd     "/home/vagrant/tr-citus"
        user    "vagrant"
        command "bin/createdb -p #{i.port} $(whoami)"
        not_if  %Q( bin/psql -tA -p #{i.port} -d postgres -c "select 1 from pg_database where datname='$(whoami)'"| grep 1 )
    end

    execute "extension-citus-#{i.name}" do
        cwd "/home/vagrant/tr-citus"
        user "vagrant"
        command <<-EOH
        bin/psql -p #{i.port} -c "create extension citus"
        EOH
        not_if %Q(bin/psql -tA -p #{i.port} -c "select 1 from pg_extension where extname='citus'"| grep 1 )
    end

end


