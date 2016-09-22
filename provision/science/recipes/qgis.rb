

package 'apt-transport-https'
package 'ca-certificates'

node['lsb']['codename'] || raise("No codename. install lsb-release?")
#
# QGis repo
#
apt_repository "qgis" do
    uri "http://qgis.org/debian"
    distribution "#{node['lsb']['codename']}"
    components ["main"]
    keyserver 'keyserver.ubuntu.com'
    key "073D307A618E5811"
end


package 'qgis'

