
$programfiles=${env:ProgramFiles(x86)}
if($programfiles -eq "") {
    $programfiles=${env:ProgramFiles}
}

function make-link
{
    $link = $args[0];
    $dest = $args[1];
    if(test-path "$link") {
        rm "$link"
    }
    cmd /c mklink  "$link" "$dest"
}

function install-vsix($url) {
    $tmpPath = "$($env:TEMP)\temp.vsix"
    (New-Object Net.WebClient).DownloadFile($url, $tmpPath)
    $cmd = 'c:\program files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\VsixInstaller.exe'
    $par = "/q /a $tmpPath"
    & "$cmd" $par.split(" ")
}
