if(Test-Path 'HKLM:\Software\BrowserChoice') {
    Set-ItemProperty -path 'HKLM:\Software\BrowserChoice' -name 'Enable' -type 'DWord' -value '0'
}
