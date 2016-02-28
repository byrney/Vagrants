
write-host "toolsroot"
cinst -y toolsroot

write-host "sysinternals"
cinst -y sysinternals

write-host "webpicmd"
cinst -y webpicmd

write-host "vim"
cinst -y vim
$gvimbin = "$programfiles\vim\vim74\gvim.exe"
$gvimlink = "c:\Users\Public\Desktop\GVim"
make-link "$gvimlink" "$gvimbin"

write-host "git"
cinst -y git

[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$programfiles\Git\bin", "Machine")

write-host "cmder mini"
cinst -y cmdermini.portable
make-link "c:\Users\Public\Desktop\Cmder" "c:\tools\cmdermini\Cmder.exe"


