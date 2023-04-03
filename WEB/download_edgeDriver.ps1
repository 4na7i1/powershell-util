#Get Edge Version
$edgePath = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'Microsoft\Edge\Application'
if(!($edgeVersion= Get-ChildItem -Name $edgePath | Where-Object { $_ -NotMatch "[a-zA-Z]+" })){Write-Error "No found Edge."}

#Set driver-download url (depend on version)
$driverURL = "https://msedgedriver.azureedge.net/$edgeVersion/edgedriver_win64.zip"
$driverZip = "./edgedriver_win64.zip"
Write-Output $driverURL

#Download driver-zip
try{
    # Start-BitsTransfer -Source $driverURL -Destination $driverZip -Asynchronous -Priority normal
    # while(!(Get-BitsTransfer | Complete-BitsTransfer)){}
    Invoke-WebRequest -Uri $driverURL -OutFile $driverZip -SkipCertificateCheck
}
catch {
    Write-Error "[ERROR] Download Zip"
}

#Expand driver-zip
$dest = "./edgeDriver/"
Expand-Archive -Path $driverZip -DestinationPath $dest -force

#Delete driver-zip
Remove-Item -Path $driverZIp -Force