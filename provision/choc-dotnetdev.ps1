write-host "Dot net dev tools"
# choco install -y visualstudiocommunity2013dex -source '\\VBOXSRV\vagrant'
choco install visualstudio2015community
cinst -y NuGet.CommandLine 
make-link "c:\Users\Public\Desktop\VS2015" "$programfiles\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"
# https://visualstudiogallery.msdn.microsoft.com/6ab922d0-21c0-4f06-ab5f-4ecd1fe7175d/file/66177/16/NUnitVisualStudioTestAdapter-2.0.0.vsix

install-vsix "https://visualstudiogallery.msdn.microsoft.com/6ab922d0-21c0-4f06-ab5f-4ecd1fe7175d/file/66177/16/NUnitVisualStudioTestAdapter-2.0.0.vsi"
install-vsix "http://www.viemu.com/ViEmuVS2013-2015-3.6.0.vsix"

