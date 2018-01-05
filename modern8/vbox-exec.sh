#vboxmanage guestcontrol "modern8" run --exe 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' --username "IEUser" --password 'Passw0rd!' -- 'echo "hello"'
function vrun(){
    vboxmanage guestcontrol modern8 run --username "IEUser" --password "Passw0rd!" -- "$@"
}

vrun net.exe use z: '\\vboxsvr\vagrant'
vrun 'c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe' 'Set-ExecutionPolicy -Scope CurrentUser -executionpolicy remotesigned -force'
vrun 'c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe' 'z:\vagrant_prepare.ps1'
#vboxmanage controlvm modern8 acpipowerbutton
#vagrant up
# $VRUN -- 'c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe' 'z:\Compact.ps1'
