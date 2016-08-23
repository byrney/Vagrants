

#32bit: http://qgis.org/downloads/QGIS-OSGeo4W-2.16.1-2-Setup-x86.exe
#64bit: http://qgis.org/downloads/QGIS-OSGeo4W-2.16.1-2-Setup-x86_64.exe
# todo: suppress reboot
windows_package 'QGIS 2.16.1 2.16.1 N\xF8debo' do
    source 'http://qgis.org/downloads/QGIS-OSGeo4W-2.16.1-2-Setup-x86.exe'
    installer_type :nsis
    #options '/S'
    not_if { ::File.exists?('c:/Program Files/QGIS 2.16.1') }
    timeout 1000
end
