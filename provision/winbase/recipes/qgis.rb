

#32bit: http://qgis.org/downloads/QGIS-OSGeo4W-2.16.1-2-Setup-x86.exe
#64bit: http://qgis.org/downloads/QGIS-OSGeo4W-2.16.1-2-Setup-x86_64.exe
# todo: suppress reboot
windows_package 'QGIS 2.16.1 2.16.1 N\xF8debo' do
    arch = case node['kernel']['os_info']['os_architecture']
           when '32-bit'
               'x86'
           when '64-bit'
                'x86_64'
           end
    source "http://qgis.org/downloads/QGIS-OSGeo4W-2.16.1-2-Setup-#{arch}.exe"
    installer_type :nsis
    options '/S /D=c:\\Tools\\QGIS'
    not_if { ::File.exists?('c:/Tools/QGIS') }
    timeout 1000
end
