
CONDA_DOWNLOAD='/var/tmp/miniconda-install.sh'
CONDA_INSTALL='/home/vagrant/conda'

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


remote_file '/home/vagrant/gor-python.tgz' do
    source 'https://github.com/google/or-tools/releases/download/v5.0/or-tools_python_examples_v5.0.3919.tar.gz'
    action :create_if_missing
    owner 'vagrant'
end

execute 'untar' do
    cwd '/home/vagrant'
    command 'tar zxf gor-python.tgz'
    user 'vagrant'
    creates 'or-tools_examples'
end

execute 'create-env' do
    command "#{CONDA_INSTALL}/bin/conda create -y -n ortools python=3.5 readline setuptools zlib"
    user 'vagrant'
    creates '/home/vagrant/.conda/envs/ortools/bin/python'
end

execute 'setup' do
    cwd '/home/vagrant/ortools_examples'
    command "/home/vagrant/.conda/envs/ortools/bin/python setup.py install"
    creates "/home/vagrant/ortools_examples/dist"
    user 'vagrant'
end

