$defenderStatus = Get-MpComputerStatus

<# Enable #>
$isEnabled = $defenderStatus.AntivirusEnabled
$realTimeProtectionEnabled = $defenderStatus.RealTimeProtectionEnabled

<# Version #>
$AMProductVersion = $defenderStatus.AMProductVersion

<# Signature Age #>
$signatureAge = ($defenderStatus.AntispywareSignatureAge -eq 4294967295) ? "useless information" : $defenderStatus.AntispywareSignatureAge
$fullScanAge = ($defenderStatus.FullScanAge -eq 4294967295) ? "useless information" : $defenderStatus.FullScanAge
$quickScanAge = ($defenderStatus.QuickScanAge -eq 4294967295) ? "useless information" : $defenderStatus.QuickScanAge

Write-Host "------ Windows Defender Settings ------"
Write-Host "* AntivirusEnabled: $isEnabled"
Write-Host "* RealTimeProtectionEnabled: $realTimeProtectionEnabled"
Write-Host "* AntiMalware Product Version: $AMProductVersion"
Write-Host "* Signature Age: $signatureAge"
Write-Host "* Scan Age (fullScan::quickScan): $fullScanAge::$quickScanAge"
