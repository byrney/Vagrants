

# choco install -y visualstudiocommunity2013dex -source '\\VBOXSRV\vagrant'
chocolatey 'visualstudio2015community'
chocolatey 'Nuget.CommandLine'

#make-link "c:\Users\Public\Desktop\VS2015" "$programfiles\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"
windows_shortcut 'c:/Users/Public/Desktop/VS2015.lnk' do
  vb = 'c:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe'
  target vb
  description "VS2015"
end

cache_dir = ENV['temp']

#install-vsix "https://visualstudiogallery.msdn.microsoft.com/6ab922d0-21c0-4f06-ab5f-4ecd1fe7175d/file/66177/16/NUnitVisualStudioTestAdapter-2.0.0.vsi"
remote_file File.join(cache_dir, 'nunit.vix') do
    source "https://visualstudiogallery.msdn.microsoft.com/6ab922d0-21c0-4f06-ab5f-4ecd1fe7175d/file/66177/16/NUnitVisualStudioTestAdapter-2.0.0.vsi"
    notifies :run, 'execute[vix-nunit]', :immediately
end

VIX = '"c:\program files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\VsixInstaller.exe"'
execute 'vix-nunit' do
    command "#{VIX} /q /a #{cache_dir}\\nunit.vix"
    action :nothing
end

