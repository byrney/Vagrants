#
# Note: this is a windows 7 compatible version of this script which doesn't
# use powershell features above v2
#
function IsWinServer
{
    $osname = (Get-WMIObject Win32_OperatingSystem).Caption | Out-String
    if($osname -match 'Server')
    {
        return $true;
    }
    return $false;
}

function UserExists([string] $username)
{
    $objOu = [ADSI]"WinNT://${env:ComputerName}"
    $localUsers = $objOu.Children | where {$_.SchemaClassName -eq 'user'}  |  % {$_.name[0].ToString().ToLower()}
    if($localUsers -contains $username.ToLower())
    {
        return $true;
    }
    return $false;
}


function Call([string]$title, $block)
{
    Write-Host '==== START ' $title
    Try
    {
        &$block
    }
    Catch [Exception] {
        Write-Host '==== ERROR ' $_.Exception.Message
        cmd /c pause | out-null
    }
    Write-Host '==== END ' $title
}

$isWinServer = IsWinServer

# Powershell Script to prepare the windows install to be used with vagrant-windows

Set-ExecutionPolicy -executionpolicy remotesigned -force

# Step 1: Disable UAC
Call 'Step 1: Disable UAC and GPO' {
        New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -PropertyType DWord -Value 0 -Force | Out-Null
        New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System -Name DisableGPO -PropertyType DWord -Value 1 -Force | Out-Null
        Write-Host "User Access Control (UAC) and group policy (GPO) has been disabled." -ForegroundColor Green
    }

# Step 2: Disable IE ESC
Call 'Step 2: Disable IE ESC' {
        if($isWinServer -eq $true)
        {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0 | Out-Null
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0 | Out-Null
            Stop-Process -Name Explorer | Out-Null
            Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
        }
        else
        {
            Write-Host 'Skip: Not a WinServer host'
        }
    }


# Step 3: Disable the shutdown tracker
# Reference: http://www.askvg.com/how-to-disable-remove-annoying-shutdown-event-tracker-in-windows-server-2003-2008/
Call 'Step 3: Disable the shutdown tracker' {
        If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability")) {
          New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability"
        }
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -PropertyType DWord -Value 0 -Force -ErrorAction continue
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonUI" -PropertyType DWord -Value 0 -Force -ErrorAction continue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -Value 0
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonUI" -Value 0
        Write-Host "Shutdown Tracker has been disabled." -ForegroundColor Green
    }


# Step 4: Disable Automatic Updates
# Reference: http://www.benmorris.me/2012/05/1st-test-blog-post.html
Call 'Step 4: Disable Automatic Updates' {
        $AutoUpdate = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
        $AutoUpdate.NotificationLevel = 1
        $AutoUpdate.Save()
        Write-Host "Windows Update has been disabled." -ForegroundColor Green
    }


# Step 5: Disable Complex Passwords
# Reference: http://vlasenko.org/2011/04/27/removing-password-complexity-requirements-from-windows-server-2008-core/
Call 'Step 5: Disable Complex Passwords' {
        $seccfg = [IO.Path]::GetTempFileName()
        secedit /export /cfg $seccfg
        (Get-Content $seccfg) | Foreach-Object {$_ -replace "PasswordComplexity\s*=\s*1", "PasswordComplexity=0"} | Set-Content $seccfg
        secedit /configure /db $env:windir\security\new.sdb /cfg $seccfg /areas SECURITYPOLICY
        del $seccfg
        Write-Host "Complex Passwords have been disabled." -ForegroundColor Green
    }

# Step 6: Enable Remote Desktop
# Reference: http://social.technet.microsoft.com/Forums/windowsserver/en-US/323d6bab-e3a9-4d9d-8fa8-dc4277be1729/enable-remote-desktop-connections-with-powershell
Call 'Step 6: Enable Remote Desktop' {
        set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0  
        set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1 
        Write-Host "Remote Desktop has been enabled" -ForegroundColor Green
    }

Call 'Step 6a: Private networking' {
        # set the ethernet network to be private before attempting to activate winrm
        # this is windows 7 version on windows 8 use get-netadapter
        $NLMType = [Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B')
        $NetworkListManager = [Activator]::CreateInstance($NLMType)
        $AllNetworks = $NetworkListManager.GetNetworks(1)
        foreach ($Network in $AllNetworks){
            $Network.SetCategory(0x01)
        }
        Write-Host "All networks have been set to private" -ForegroundColor Green
    }

# Step 7: Enable WinRM Control
Call 'Step 7: Enable WinRM Control' {
        winrm quickconfig -q
        winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}' | out-null
        winrm set winrm/config '@{MaxTimeoutms="1800000"}' | out-null
        winrm set winrm/config/service '@{AllowUnencrypted="true"}' | out-null
        winrm set winrm/config/service/auth '@{Basic="true"}' | out-null
        # make winrm start auto  (no ps command for this)
        invoke-expression "sc.exe config winrm start= auto"
        Write-Host "WinRM has been configured and enabled." -ForegroundColor Green
    }


# Step 8: Disable Windows Firewall
Call 'Step 8: Disable Windows Firewall' {
        &netsh "advfirewall" "set" "allprofiles" "state" "off"
        Write-Host "Windows Firewall has been disabled." -ForegroundColor Green
    }

# Step 9: Create local vagrant user
Call 'Step 9: Create local vagrant user' {
        $userexists = UserExists('vagrant')
        if($userexists -eq $false)
        {
            $userDirectory = [ADSI]"WinNT://localhost"
            $user = $userDirectory.Create("User", "vagrant")
            $user.SetPassword("vagrant")
            $user.SetInfo()
            $user.UserFlags = 64 + 65536 # ADS_UF_PASSWD_CANT_CHANGE + ADS_UF_DONT_EXPIRE_PASSWD
            $user.SetInfo()
            $user.FullName = "vagrant"
            $user.SetInfo()
            &net "localgroup" "administrators" "/add" "vagrant"
            Write-Host "User: 'vagrant' has been created as a local administrator." -ForegroundColor Green
        }
        else
        {
            Write-Host "vagrant user already exists."
        }
    }

# Step 10: Create local vagrant user
Call 'Step 10: Disable some bothersome services' {
        invoke-expression "sc.exe config aelookupsvc start= disabled"
        invoke-expression "sc.exe config pcasvc start= disabled"
    }

Call 'Step 10: install chef client' {
    if(test-path "c:\opscode\chef\bin\chef-client") {
        write-host "Chef already installed"
        return
    }
    $chefUrl = "https://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/i386/chef-client-12.5.1-1-x86.msi"
    $tempDir = $env:Temp
    $file = Join-Path $tempDir "chef-install.msi"

    # download the package
    if(test-path $file){
        write-host "msi already downloaded at $file"
    } else {
      write-host "Downloading chef MSI from $chefUrl"
      $downloader = new-object System.Net.WebClient
      $downloader.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials;
      $downloader.DownloadFile($chefUrl, $file)
    }
    write-host "Installing chef msi $file"
    & cmd /c msiexec /qn /i "$file"
    Write-Host "Chef Client has been installed" -ForegroundColor Green
}

Write-Host "Restarting Computer." -ForegroundColor Yellow

cmd /c pause | out-null

Restart-Computer
