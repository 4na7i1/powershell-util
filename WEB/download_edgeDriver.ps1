# Download the appropriate msedgedriver according to the version of edge
# [Example] ./download_edgeDriver
#  [options] -force : Flag whether to overwrite the driver even if you have already downloaded the appropriate version driver
# [Memo] 
[CmdletBinding()]param([switch]$force)

#Get Edge Version
$edgePath = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'Microsoft\Edge\Application'
if(!($edgeVersion= Get-ChildItem -Name $edgePath | Where-Object { $_ -NotMatch "[a-zA-Z]+" })){Write-Error "No found Edge."}

#Set driver-download url (depend on version)
$driverURL = "https://msedgedriver.azureedge.net/$edgeVersion/edgedriver_win64.zip"
$driverZip = "./edgedriver_win64.zip"
Write-Output $driverURL


#Download driver-zip
#check already driver-zip
$edgeDriverPath = "./edgeDriver/"
if((Test-Path "./edgeDriver/msedgedriver_$edgeVersion.exe") -and !($force)){Write-Output "edge driver is up-to-date";Exit}
else{Remove-Item -Path $edgeDriverPath -Include "*.exe" -Force}
try{
    # Start-BitsTransfer -Source $driverURL -Destination $driverZip -Asynchronous -Priority normal
    # while(!(Get-BitsTransfer | Complete-BitsTransfer)){}
    Invoke-WebRequest -Uri $driverURL -OutFile $driverZip -SkipCertificateCheck
}
catch {
    Write-Error "[ERROR] Download Zip"
    Remove-Item -Path $driverZip -Force
}

#Expand driver-zip
Expand-Archive -Path $driverZip -DestinationPath $edgeDriverPath -force

#Delete driver-zip,junk files
Remove-Item -Path $driverZip -Force
Remove-Item -Path $edgeDriverPath -Exclude "msedgedriver.exe" -Force -Recurse
#Change driver-name
Rename-Item -Path "$edgeDriverPath/msedgedriver.exe" -NewName "msedgedriver_$edgeVersion.exe"