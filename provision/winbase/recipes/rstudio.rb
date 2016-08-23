
windows_package 'R for Windows 3.3.1' do
    source 'https://cran.r-project.org/bin/windows/base/R-3.3.1-win.exe'
    installer_type :custom
    options '/SILENT'
end

windows_path 'C:\Program Files\R\R-3.3.1\bin\i386' do
    action :add
end

windows_package 'Rtools 3.3' do
    source 'https://cran.r-project.org/bin/windows/Rtools/Rtools33.exe'
    installer_type :custom
    options '/SILENT'
end

windows_path 'C:\Rtools\bin' do
    action :add
end

windows_package 'RStudio' do
    source 'https://download1.rstudio.org/RStudio-0.99.903.exe'
    installer_type :custom
    options '/S'
end

#C:\Program Files\RStudio\bin
windows_shortcut 'c:/Users/Public/Desktop/RStudio.lnk' do
  vb = 'C:/Program Files/RStudio/bin/rstudio.exe'
  target vb
  description "RStudio"
end
# https://github.com/git-for-windows/git/releases/download/v2.9.3.windows.1/Git-2.9.3-64-bit.exe
