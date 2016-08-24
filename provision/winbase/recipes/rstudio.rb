
RDIR='c:\Tools\R'

windows_package 'R for Windows 3.3.1' do
    source 'https://cran.r-project.org/bin/windows/base/R-3.3.1-win.exe'
    installer_type :custom
    options "/SILENT /DIR=#{RDIR}\\R-3.3.1"
end

windows_path "#{RDIR}\\R-3.3.1\\bin\\i386" do
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
# https://github.com/git-for-windows/git/releases/download/v2.9.3.windows.1/Git-2.9.3-64-bit.exe
