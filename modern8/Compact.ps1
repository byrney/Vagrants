
# Shrink the pagefile

$System = GWMI Win32_ComputerSystem -EnableAllPrivileges
$System.AutomaticManagedPagefile = $False
$System.Put()

$CurrentPageFile = gwmi -query "select * from Win32_PageFileSetting where name='c:\\pagefile.sys'"
if( $CurrentPageFile.InitialSize -gt 512 ) {
    $CurrentPageFile.InitialSize = 512
    $CurrentPageFile.MaximumSize = 512
    $CurrentPageFile.Put()
}

# remove any windows apps

Get-AppxPackage -AllUsers | Remove-AppxPackage

pause

# clear out WinSXS

Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

# run disk cleanup

C:\Windows\System32\cleanmgr.exe /d c:

Get-WindowsFeature |
? { $_.InstallState -eq 'Available' } |
Uninstall-WindowsFeature -Remove

pause


Optimize-Volume -DriveLetter C


pause

wget http://download.sysinternals.com/files/SDelete.zip -OutFile c:\sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\sdelete.zip", "c:\")
c:\sdelete.exe -z c:


