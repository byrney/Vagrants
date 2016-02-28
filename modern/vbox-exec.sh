#vboxmanage guestcontrol "modern8" run --exe 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' --username "IEUser" --password 'Passw0rd!' -- 'echo "hello"'
vboxmanage guestcontrol "modern8" run --exe 'schtasks.exe' --username "IEUser" --password 'Passw0rd!' -- ' /run /tn \\vboxsvr\vagrant\vagrant_prepare.ps1'

