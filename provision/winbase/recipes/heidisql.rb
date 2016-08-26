#http://www.heidisql.com/installers/HeidiSQL_9.3.0.4984_Setup.exe


#
# Note: no https to download the installed and .exe over http is blocked
# by AV

windows_zipfile 'HeidiSQL' do
    source 'http://www.heidisql.com/downloads/releases/HeidiSQL_9.3_Portable.zip'
    action :unzip
    not_if {::File.exists?('c:/Tools/HeidiSQL') }
    path 'c:/Tools/HeidiSQL'
end

windows_shortcut 'c:/Users/Public/Desktop/HeidiSQL.lnk' do
  vb = 'c:/Tools/HeidiSQL/HeidiSQL.exe'
  target vb
  description "HeidiSQL"
end

# ::Chef::Recipe.send(:include, Windows::Helper)
# hash_of_installed_packages = installed_packages
# puts hash_of_installed_packages.inspect
