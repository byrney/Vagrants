
cinst SQL2012.DACFramework 
if(!(test-path -path c:\tmp\SSDTSetup.exe))
{
	write-host "Downloading SSDT"
	Invoke-webrequest http://go.microsoft.com/fwlink/?LinkID=400928 -OutFile c:\tmp\SSDTSetup.exe
}
write-host "Installing SSDT"
start-process -wait -verb runas "c:\tmp\SSDTSetup.exe" -argumentList '/silent /log c:\tmp\ssdt.log'
write-host "SSDT Complete"
