<#
 # Privilege Escalation
 #>

param (
    [switch]$DisableLimitedUAC,
    [switch]$DisableRemoteUAC
)

function Set-RegistryValue {
    param (
        [string]$regPath,
        [string]$regName,
        $regValue
    )

    Set-ItemProperty -Path $regPath -Name $regName -Value $regValue
    Write-Host "Registry value updated:"
    Write-Host "\tPath: $regPath"
    Write-Host "\tName: $regName"
    Write-Host "\tValue: $regValue"
}

if ($DisableLimitedUAC) {
    Set-RegistryValue -regPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -regName "EnableLUA" -regValue "0"
}

if ($DisableRemoteUAC) {
    Set-RegistryValue -regPath "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -regName "LocalAccountTokenFilterPolicy" -regValue 1
}
