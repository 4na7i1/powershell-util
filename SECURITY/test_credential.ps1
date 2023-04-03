# test-file:module_credential.psm1

# Import Module
Import-Module -Name "$($PSScriptRoot)\module_sec\module_credential.psm1" -Force

# Create Credential Json File
Get-CredentialJSON

# Get Credential Json File
$credentialFiles = get-childitem -path "./" -Filter "*.json"

foreach($credentialFile in $credentialFiles){
    Write-Output "`n>> ($credentialFile) <<"
    Read-CredentialJSON -crFilePath $credentialFile | Format-Table
}