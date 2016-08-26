#https://github.com/git-for-windows/git/releases/download/v2.9.3.windows.1/Git-2.9.3-32-bit.exe


windows_package 'Git version 2.9.3' do
    bitness = node['kernel']['os_info']['os_architecture']
    source "https://github.com/git-for-windows/git/releases/download/v2.9.3.windows.1/Git-2.9.3-#{bitness}.exe"
    installer_type :inno
end
