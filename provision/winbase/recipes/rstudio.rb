
RDIR='c:\Tools\R'
TEMPDIR=ENV['TEMP']

windows_package 'R for Windows 3.3.1' do
    source 'https://cran.r-project.org/bin/windows/base/R-3.3.1-win.exe'
    installer_type :custom
    options "/SILENT /DIR=#{RDIR}\\R-3.3.1"
end

windows_path "#{RDIR}\\R-3.3.1\\bin\\i386" do
    arch = case node['kernel']['os_info']['os_architecture']
           when '32-bit'
               'i386'
           when '64-bit'
                'x64'
           end
    path "#{RDIR}\\R-3.3.1\\bin\\#{arch}"
    action :add
end

windows_package 'Rtools 3.3' do
    source 'https://cran.r-project.org/bin/windows/Rtools/Rtools33.exe'
    installer_type :custom
    options "/SILENT /DIR=#{RDIR}\\Rtools"
end

windows_path "#{RDIR}\\tools\\bin" do
    action :add
end

windows_package 'RStudio' do
    source 'https://download1.rstudio.org/RStudio-0.99.903.exe'
    installer_type :custom
    options "/S /D=#{RDIR}\\Rstudio"
end

windows_shortcut 'c:/Users/Public/Desktop/RStudio.lnk' do
  vb = "#{RDIR}/RStudio/bin/rstudio.exe"
  target vb
  description "RStudio"
end

#
# postgres ODBC drivers for use in R
#
windows_zipfile TEMPDIR do
    arch = case node['kernel']['os_info']['os_architecture']
           when '32-bit'
               'x86'
           when '64-bit'
                'x64'
           end
    source "https://ftp.postgresql.org/pub/odbc/versions/msi/psqlodbc_09_05_0400-#{arch}.zip"
    action :unzip
end

windows_package 'psqlODBC' do
    arch = case node['kernel']['os_info']['os_architecture']
           when '32-bit'
               'x86'
           when '64-bit'
                'x64'
           end
    source "#{TEMPDIR}/psqlodbc-#{arch}.msi"
end

