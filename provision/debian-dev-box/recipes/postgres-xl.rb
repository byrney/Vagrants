
package 'jade'
package 'sgml-data'
package 'docbook-dsssl'
package 'build-essential'
package 'libreadline6-dev'
package 'bison'
package 'flex'
package 'zlib1g-dev'

version = "postgres-xl95r1beta1"

user 'pgxl' do
    home '/home/pgxl'
    shell '/bin/bash'
end

directory "/home/pgxl" do
  owner "pgxl"
  group "pgxl"
  mode 00755
  action :create
end

# pgxc_ctl expects to ssh to localhost without a password
# or known_hosts check. Create some new ssh keys and add to auth_keys
execute "generate ssh keys" do
    user 'pgxl'
    creates "/home/pgxl/.ssh/id_rsa.pub"
    command "ssh-keygen -t rsa -q -f /home/pgxl/.ssh/id_rsa -P \"\" && cat /home/pgxl/.ssh/id_rsa.pub >> /home/pgxl/.ssh/authorized_keys"
end

# disable the known host check for local connections
template '/home/pgxl/.ssh/config' do
    source 'disable-strict-host.erb'
    mode '0600'
    owner 'pgxl'
end

# download the tarball from 2nd quadrant and expand into ~pgxl
ark "postgres-xl" do
    url "http://files.postgres-xl.org/#{version}.tar.gz"
    path "/home/pgxl/"
    prefix_root '/usr/local'
    action [:put]
    owner 'pgxl'
end

execute 'configure' do
    command "./configure --prefix=/usr/local "
    cwd "/home/pgxl/postgres-xl"
    user 'pgxl'
    creates '/home/pgxl/postgres-xl/src/Makefile.global'
end

execute 'make-xl' do
    command "make"
    cwd "/home/pgxl/postgres-xl"
    user 'pgxl'
end

execute 'make-ctl' do
    command "cd 'contrib/pgxc_ctl' && make "
    cwd '/home/pgxl/postgres-xl'
    user 'pgxl'
    creates '/usr/local/bin/pgxc_ctl'
end

execute 'install-xl' do
    command "make install"
    cwd "/home/pgxl/postgres-xl"
    creates '/usr/local/bin/psql'
end

execute 'install-ctl' do
    command "cd 'contrib/pgxc_ctl' && make install"
    cwd '/home/pgxl/postgres-xl'
    creates '/usr/local/bin/pgxc_ctl'
end

directory '/home/pgxl/DATA' do
    owner 'pgxl'
    group 'pgxl'
end

# directory '/home/vagrant/pgxc_ctl' do
#     owner 'vagrant'
# end

template '/home/pgxl/pgxc_ctl.in' do
    source 'pgxc_ctl.erb'
    owner 'pgxl'
end

execute 'pgxc-config' do
    command ' echo "prepare config empty
            exit" | pgxc_ctl '
    user 'pgxl'
    creates '/home/pgxl/pgxc_ctl.conf'
    environment ({ 'HOME' => '/home/pgxl', 'USER' => 'pgxl' })
end

execute 'pgxc-setup' do
    command "pgxc_ctl < '/home/pgxl/pgxc_ctl.in' | tee /home/pgxl/pgxc_ctl.setup"
    user 'pgxl'
    cwd '/home/pgxl'
    creates '/home/pgxl/pgxc_ctl.setup'
    environment ({ 'HOME' => '/home/pgxl', 'USER' => 'pgxl' })
end

# Start does not work because the /home/pgxl/pgxc_ctl/xx.conf script
# has some non-ascii chars in it.  Things like   ;<90> need to be removed
# execute 'start-all' do
#     command 'pgxc_ctl start all'
#     user 'pgxl'
#     cwd '/home/pgxl'
#     environment ({ 'HOME' => '/home/pgxl', 'USER' => 'pgxl' })
# end


