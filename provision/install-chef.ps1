
$chefUrl = "http://www.opscode.com/chef/install.msi"
$tempDir = $env:Temp
$file = Join-Path $tempDir "chef-install.msi"

# download the package
if(test-path $file){
    write-host "msi already downloaded at $file"
} else {
  $downloader = new-object System.Net.WebClient
  $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;
  $downloader.DownloadFile($chefUrl, $file)
}

write-host "Installing chef msi $file"
& cmd /c msiexec /qn /i "$file"

