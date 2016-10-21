

#
# Install R and Rstudio from CRAN on debian
#
# https://cran.rstudio.com/bin/linux/debian/

node.default['r']['cran_mirror'] = 'https://www.stats.bris.ac.uk/R/'
package 'apt-transport-https' if node['platform_family'] == 'debian'
package 'ca-certificates'
package 'build-essential'

#
# R base first
#
apt_repository 'cran' do
    uri 'http://cran.rstudio.com/bin/linux/ubuntu'
    key 'E084DAB9'
    distribution "#{node['lsb']['codename']}/"   #  note '/' required at end
end

package %W(r-base r-base-dev)

#
# Other usefuls required for gdal and database access
#
package ['unixodbc', 'unixodbc-dev', 'libgdal-dev', 'libproj-dev', 'proj-bin', 'proj-data', 'libcurl4-openssl-dev']

#
# Ensure packrat is available in the base R install
#
execute 'install-packrat' do
    command %Q[Rscript -e "install.packages('packrat', repos='https://www.stats.bris.ac.uk/R/')"]
end

#  NEED to export TAR=/bin/tar for R packages to build

