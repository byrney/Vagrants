
package 'apt-transport-https'
package 'ca-certificates'

node['lsb']['codename'] || raise("No codename. install lsb-release?")
#
# OM install
#
apt_repository "openmodelica" do
    uri "http://build.openmodelica.org/apt"
    distribution "#{node['lsb']['codename']}"
    components ["stable"]
    key "http://build.openmodelica.org/apt/openmodelica.asc"
end


package 'openmodelica'

