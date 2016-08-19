
#
# Install R and Rstudio from CRAN on debian
#
# https://cran.rstudio.com/bin/linux/debian/

package 'apt-transport-https' if node['platform_family'] == 'debian'
package 'ca-certificates'

#
# Add cran repo
#
apt_repository "cran" do
    uri "http://mirrors.ebi.ac.uk/CRAN/bin/linux/debian"
    distribution "#{node['lsb']['codename']}-cran3"
    keyserver 'keys.gnupg.net'
    key "381BA480"
    component ['main']
    #key "cran-pgp.asc"
end

#
# Install R
#
package ['r-base', 'r-base-dev']

#
# rstudio debpendencies
#  -- these are old versions and do not get installed automatically
package ['liborc-0.4-0', 'libgstreamer0.10-0', 'libgstreamer-plugins-base0.10-0', 'libxslt1.1']

#
# rstudio install
#
remote_file '/home/vagrant/rstudio.deb' do
    source 'https://download1.rstudio.org/rstudio-0.99.903-amd64.deb'
    owner 'vagrant'
    group 'vagrant'
    action :create
    #checksum '98ea59d3db00e0083d3e4053514f764d'
end

dpkg_package 'rstudio.deb' do
    source "/home/vagrant/rstudio.deb"
end

#
# Other usefuls
#
package ['unixodbc', 'libgdal-dev']

