cd $env:TEMP
$berks = @'

source "https://supermarket.chef.io"
cookbook 'dssetup', path: './dssetup/'

'@
 
$runlist = @'

  { 
    "run_list": [ "recipe[dssetup::default]" ] 
  }

'@

$chefConfig = @'

    here = File.expand_path(File.dirname(__FILE__))
    file_cache_path "#{here}/.cache"
    cookbook_path "#{here}/berks-cookbooks"
    json_attribs "#{here}/node.json"

'@

$berks | out-file -encoding ascii -filepath $env:TEMP/Berksfile
$runlist | out-file -encoding ascii -filepath $env:TEMP/node.json
$chefConfig | out-file -encoding ascii -filepath $env:TEMP/chef-config.rb

$url="https://packages.chef.io/stable/windows/2008r2/chef-client-12.13.37-1-x86.msi"
echo "Downloading Chef..."
(new-object System.Net.WebClient).DownloadFile($url, "$env:TEMP/chef.msi")
echo "Installing chef..."
& msiexec /i chef.msi /passive | Out-Null
& c:\opscode\chef\embedded\bin\gem.bat install berkshelf --no-rdoc | out-null
& c:\opscode\chef\embedded\bin\berks.bat install | write-output
& c:\opscode\chef\embedded\bin\berks.bat vendor | write-output
& c:\opscode\chef\bin\chef-solo -c chef-config.rb -j node.json


