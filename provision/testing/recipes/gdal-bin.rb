#
# dependencies
#
package %W(curl build-essential libxml2-dev expat pkg-config postgresql-server-dev-9.5
libxerces-c-dev libxerces-c3.1)

ark 'gdal-bin' do
    url 'http://download.osgeo.org/gdal/2.1.1/gdal-2.1.1.tar.gz'
    action [:configure, :install_with_make]
    prefix_root '/usr/local'
    version '2.1.1'
end
