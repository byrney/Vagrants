
#
# Install R and Rstudio from CRAN on debian
#
# https://cran.rstudio.com/bin/linux/debian/

include_recipe "debian-base-box::xorg"
include_recipe "science::r-base"

# #
# # rstudio debpendencies
# #  -- these are old versions and do not get installed automatically
package ['liborc-0.4-0', 'libgstreamer0.10-0', 'libgstreamer-plugins-base0.10-0', 'libxslt1.1', 'libjpeg62']

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
