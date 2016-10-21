
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

# execute 'r-environment' do
#     command "#{CONDA_INSTALL}/bin/conda create --quiet --yes -c r -n r-base r"
# #    not_if { File.exists?("#{CONDA_INSTALL}/bin/conda") }
# end
