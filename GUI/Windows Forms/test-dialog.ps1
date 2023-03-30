# Import Module
Import-Module -Name "$($PSScriptRoot)\module\module_dialog.psm1" -Force

# EXAMPLE
# $rtn = Open-folderDialog
$rtn = Open-inputDialog

Write-Output "$rtn"