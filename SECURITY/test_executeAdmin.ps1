# test-file:module_executeAdmin.psm1

# Import Module
Import-Module -Name "$($PSScriptRoot)\module_sec\module_executeAdmin.psm1" -Force

runAs $PSCommandPath $((Get-Location).Path)

