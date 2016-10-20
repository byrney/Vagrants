
remote_file '/var/tmp/miniconda.sh' do
    source 'https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh'
end

execute 'conda-install' do
    command 'bash /var/tmp/miniconda.sh -b -p /usr/local/miniconda'
    not_if { File.exists?("/usr/local/miniconda/bin/conda") }
end

execute 'anaconda-cli' do
    command '/usr/local/miniconda/bin/conda install anaconda-client'
    not_if { File.exists?("/usr/local/miniconda/bin/anaconda") }
end
