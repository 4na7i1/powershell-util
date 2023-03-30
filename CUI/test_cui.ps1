# Import Module
Import-Module -Name "$($PSScriptRoot)\module_cui" -Force

# EXAMPLE
Clear-Host;
firstLine;
middleLine;
middleLine "`nAAAA`nnnBBBB"; # => ?
middleLine "ABCD";
middleLine "1234";
middleLine "ABCD 1234 ";
middleLine ("A" * ($host.UI.RawUI.WindowSize.Width));
middleLine ("A" * ($host.UI.RawUI.WindowSize.Width-1));
middleLine ("A" * ($host.UI.RawUI.WindowSize.Width-2));
middleLine $(Get-Location);
middleLine $(Get-Date);
endLine;