
CONDAPATH='c:/pkgs'  # cant seem to change this for installer

case node['kernel']['os_info']['os_architecture']
when '32-bit'
    windows_package 'Python 3.5.2 (Miniconda3 4.1.11 32-bit)' do
        source 'https://repo.continuum.io/miniconda/Miniconda3-4.1.11-Windows-x86.exe'
        installer_type :custom
        options "/S /InstallationType=AllUsers /D=#{CONDAPATH}"
    end
when '64-bit'
    windows_package 'Python 3.5.2 (Miniconda3 4.1.11 64-bit)' do
        source 'https://repo.continuum.io/miniconda/Miniconda3-4.1.11-Windows-x64.exe'
        installer_type :custom
        options "/S /InstallationType=AllUsers /D=#{CONDAPATH}"
    end
end

execute 'install-jupyter' do
    command "#{CONDAPATH}/Scripts/conda install --yes --quiet jupyter"
    creates "#{CONDAPATH}/Scripts/jupyter.exe"
end

# anaconda full package
# https://repo.continuum.io/archive/Anaconda3-4.1.1-Windows-x86.exe

