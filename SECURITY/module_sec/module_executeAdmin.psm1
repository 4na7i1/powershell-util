function test {
    [CmdletBinding()]param($psFilePath,$psFileDirectory)
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")){ 
        # $sqFile = "$(Get-Location)\Client_offline.xml"
        Write-Output "No Administrators"

        Start-Process powershell.exe "-File `"$psFilePath`" -WorkingDirectory `"$psFileDirectory`" " -Verb RunAs #-Wait
        exit
    }
    else{
        Write-Output "Administrators"
        # $isAdmin = $true
    }
}