
CONDA_DOWNLOAD='/var/tmp/miniconda-install.sh'
CONDA_INSTALL='/usr/local/lib/miniconda'

package %W(binutils devscripts)

remote_file CONDA_DOWNLOAD do
    source 'https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh'
end

execute 'install-conda' do
    command "bash #{CONDA_DOWNLOAD} -b -p #{CONDA_INSTALL}"
    not_if { File.exists?("#{CONDA_INSTALL}/bin/conda") }
end

execute 'anaconda-client' do
    command "#{CONDA_INSTALL}/bin/conda install anaconda-client"
    not_if { File.exists?("#{CONDA_INSTALL}/bin/anaconda") }
end


package %W( git )


remote_file '/home/vagrant/cplex.bin' do
    source 'https://www15.software.ibm.com/sdfdl/v2/fulfill/CNFC1ML/Xa.2/Xb.apj9sOpp4HFydq-OJixueMbDa3V4Br-tuNSfqMT8EJE/Xc.CNFC1ML/COSCE127LIN64.bin/Xd./Xf.LPR.D1VC/Xg.8930699/Xi.ESD-ILOG-OPST-EVAL/XY.regsrvs/XZ.3qg2bLPq0OEhI6lg6iNu2gmMfnM/COSCE127LIN64.bin'
end

# mkdir -p build
directory '/home/vagrant/gurobi' do
    owner 'vagrant'
end

remote_file '/home/vagrant/gurobi/gurobi.tgz' do
    source 'http://packages.gurobi.com/7.0/gurobi7.0.1_linux64.tar.gz'
    action :create_if_missing
    owner 'vagrant'
end

execute 'extract' do
    command 'tar zxf gurobi.tgz'
    creates 'gurobi701'
    cwd '/home/vagrant/gurobi'
end

