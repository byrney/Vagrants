

if(!(test-path -path c:\tmp\vsnuget.vsi))
{
	write-host "Downloading NUGET VSI"
	Invoke-webrequest http://visualstudiogallery.msdn.microsoft.com/4ec1526c-4a8c-4a84-b702-b21a8f5293ca/file/105933/6/NuGet.Tools.2013.vsix OutFile c:\tmp\vsnuget.vsi
}
write-host "Installing NUGET VS Addon"
start-process -wait -verb runas "c:\tmp\nsnuget.vsi" -argumentList '/silent /log c:\tmp\vsnuget.log'
write-host "NUGET Complete"
