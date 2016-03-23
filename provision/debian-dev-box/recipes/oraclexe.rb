# apt-get install apt-transport-https ca-certificates

package 'libaio1'
package 'net-tools'
package 'bc'

chunks = ['aa', 'ab', 'ac']
base = 'https://github.com/byrney/docker-oracle-xe-11g/raw/master/assets/'
deb = "oracle-xe_11.2.0-1.0_amd64.deb"


link '/bin/awk' do
    to '/usr/bin/awk'
end

directory '/var/local/subsys' do

end

remote_file "/sbin/chkconfig" do
    source "#{base}/chkconfig"
    mode '0755'
    action :create_if_missing
end

chunks.each do |chunk|
    remote_file "/tmp/#{deb}#{chunk}" do
        source "#{base}/#{deb}#{chunk}"
        owner 'vagrant'
        action :create_if_missing
        not_if { File.exists?("/home/vagrant/#{deb}") }
    end
end

execute 'concat' do
    command "cat /tmp/oracle-xe_11.* > #{deb}"
    cwd "/home/vagrant"
    user "vagrant"
    creates "/home/vagrant/#{deb}"
end

dpkg_package 'oracle-xe' do
    source "/home/vagrant/#{deb}"
end

execute 'template' do
    command 'mv /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora.tmpl'
    creates '/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora.tmpl'
end

bash 'startup' do
    code <<-'EOH'
        LISTENERS_ORA=/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
        sed 's/%hostname%/$HOSTNAME/g ;s/%port%/1521/g' "${LISTENERS_ORA}.tmpl" > "$LISTENERS_ORA"
        # sed -i "s/%hostname%/$HOSTNAME/g" "${LISTENERS_ORA}" &&
        # sed -i "s/%port%/1521/g" "${LISTENERS_ORA}" &&
    EOH
    creates '/u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora'
end

remote_file '/u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora' do
    source "#{base}/init.ora"
end

remote_file '/u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora' do
    source "#{base}/initXETemp.ora"
end

bash 'configure' do
    code <<-'EOF'
        printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure
    EOF
    creates '/etc/oratab'
end

bash 'env' do
    code <<-'EOH'
        echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/bash.bashrc &&
        echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc &&
        echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc
        echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' > /etc/profile.d/oracle.sh &&
        echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/profile.d/oracle.sh &&
        echo 'export ORACLE_SID=XE' >> /etc/profile.d/oracle.sh
    EOH
    creates '/etc/profile.d/oracle.sh'
end

remote_file '/home/vagrant/ora-start.sh' do
    source "#{base}/startup.sh"
    mode '0755'
end

service 'oracle-xe' do
    action [:enable, :start]
end

