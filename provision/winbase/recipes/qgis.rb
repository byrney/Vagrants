
#http://qgis.org/downloads/QGIS-OSGeo4W-2.16.1-2-Setup-x86_64.exe


# todo: suppress reboot
windows_package 'QGis' do
    source 'http://qgis.org/downloads/QGIS-OSGeo4W-2.16.1-2-Setup-x86_64.exe'
    installer_type :custom
    options '/S'
end


