

package 'apt-transport-https'
package 'ca-certificates'

node['lsb']['codename'] || raise("No codename. install lsb-release?")
#
# QGis repo
#
apt_repository "postgresql" do
    uri "http://qgis.org/debian"
    distribution "#{node['lsb']['codename']}"
    components ["main"]
    keyserver 'keyserver.ubuntu.com'
    key "http://qgis.org/downloads/qgis-2015.gpg.key"
end


package 'qgis'

