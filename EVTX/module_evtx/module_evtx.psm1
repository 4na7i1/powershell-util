function Get-EventLogSizeParallel {
    <# GET EVENTLOG SIZE #>
    <# [!] Most likely a bug. Use Get-EventLogSize #>
    param ($logs)
    if($null -eq $logs){$logs = wevtutil el}

    $length = $logs.Count
    $result = @{i = 0;size=0}
    $sync = [System.Collections.Hashtable]::synchronized($result)

    $job = $logs | ForEach-Object -AsJob -ThrottleLimit 10 -Parallel {
        $sqCopy = $Using:sync
        [String]$return = wevtutil gli $_ | Select-String -Pattern "fileSize: " -Encoding UTF8
        if($null -ne $return){
            $r = $return -split "fileSize: "
            if($null -ne $r[1]){
                # $r[1]
                $sqCopy.size += [int]$r[1]
            }
        }
        $sqCopy.i++
    }

    #While $job is running, update progress bar
    while ($job.State -eq 'Running') {
        if ($sync.i -gt 0) {
            $status = (($sync.i / $length) * 100)
            Write-Progress -Activity "[$env:computername] Count Log Size" -Status "Progress" -PercentComplete $status
            Start-Sleep -Milliseconds 100
        }
    }

    # $result
    $machine = $env:computername 
    $result = $sync.size / 1MB
    Write-Output "$machine :: $result [MB]"
}

function Get-EventLogSize{
    param()
    $C = $env:homedrive
    $sum = 0
    [String]$logPath = $C + "/Windows/System32/winevt/Logs"
    $logs = (Get-ChildItem -Path $logPath -Recurse -Force) 
    foreach ($l in $logs) {
        $sum += $l.Length
    }

    $result = $sum /1MB
    $machine = $env:computername 
    Write-Output "$machine :: $result [MB]"
    # return $result
}

function Clear-EventLogParallel {
    <# CLEAR EVENTLOG #>
    param ($logs)
    if($null -eq $logs){$logs = wevtutil el}

    $length = $logs.Count
    $result = @{i = 0}
    $sync = [System.Collections.Hashtable]::synchronized($result)
    
    $job = $logs | ForEach-Object -AsJob -ThrottleLimit 6 -Parallel {
        $sqCopy = $Using:sync
        wevtutil cl $_ > $null
        $sqCopy.i++
    }
    
    #While $job is running, update progress bar
    while ($job.State -eq 'Running') {
        if ($sync.i -gt 0) {
            $status = (($sync.i / $length) * 100)
            Write-Progress -Activity "Reset EventLog" -Status "Progress" -PercentComplete $status
            Start-Sleep -Milliseconds 100
        }
    }
    
    Write-Output "[$env:computername] Complete Reset EventLog"
}

function Clear-EventLogSingle {
    <# CLEAR EVENTLOG #>
    param ($logs)
    if($null -eq $logs){$logs = wevtutil el}

    foreach($log in $logs){
        wevtutil cl $log
    }
    
    Write-Output "[$env:computername] Complete Reset EventLog"
}

function Get-SumLogSize{

    param([string]$result)
    $array = $result.Split(" :: ").Split("[MB]")

    $sum = 0
    $i = 1
    foreach($a in $array){
        if($i % 2 -eq 0){$sum += $a}
        $i++
    }
    return $sum
}

function Open-logPath {
    param ()
    $C = $env:homedrive
    [String]$logPath = $C + "/Windows/System32/winevt/Logs"
    [String]$nowPath = (Get-Location).Path

    Set-Location $logPath
    explorer.exe .
    Set-Location $nowPath
}


function Convert-EvtxToXML {
    # Convert evtx file to xml file
    # [Example] ./convert-evtx-xml -basepath "(folder or evtx file path)
    #  [options] 
    #    -overwrite : Flag whether to process for those already converted to xml
    #    -output : Flag whether the converted xml should be written to a file or not
    [CmdletBinding()]param([switch]$output,[switch]$overwrite,[Alias("PSPath")][string[]]$basePath)

    if ($basePath) {
        # if([System.IO.Path]::GetExtension($basePath)){$evtxFiles = $basePath}
        # else{$evtxFiles = Get-ChildItem -LiteralPath $basePath -Filter "*.evtx" -Recurse}
        $evtxFiles = Get-ChildItem -LiteralPath $basePath -Filter "*.evtx" -Recurse
    }
    else{
        $basePath = (Get-Location).Path
        $evtxFiles = Get-ChildItem -Path $basePath -Filter "*.evtx" -Recurse
    }
    
    if($evtxFiles.count -eq 0){Write-Host "NO evtx files in $basePath ";EXIT}
    # elseif(($evtxFiles.count -ge 2) -and (!$output)){$xmlArray = New-Object System.Collections.ArrayList}
    
    $xmlArray = New-Object System.Collections.ArrayList

    foreach($evtxFile in $evtxFiles){
        Write-Host "[evtx -> xml] $evtxFile"
        $xmlFile = Join-Path -Path $evtxFile.Directory.FullName -ChildPath ($evtxFile.BaseName + ".xml")
        if(!(Test-Path $xmlFile) -or $overwrite){
            if($output){
                (wevtutil qe $evtxFile /lf /rd:false /e:root /f:xml) > $xmlFile
                Write-Host "Done: $xmlFile"
            }
            else{
                Write-Host "B"
                $ErrorActionPreference = 'SilentlyContinue' #Avoid MetadataError
                # [XML]$xml = wevtutil qe $evtxFile /lf /rd:false /e:root /f:xml
                [XML]$xml = wevtutil qe "./example_evtx/sysmon/sysmon.evtx" /lf /f:XML /rd:false /e:root
                $ErrorActionPreference = 'Continue'
                Write-Host $xml
                $xmlArray.Add($xml) > $null
            }
        }
        else{
            if($output){
                Write-Host "Already Done: $xmlFile"
            }
            else{
                Write-Host "D"
                $ErrorActionPreference = 'SilentlyContinue' #Avoid MetadataError
                [XML]$xml = wevtutil qe $evtxFile /lf /rd:false /e:root /f:xml
                $ErrorActionPreference = 'Continue'
                $xmlArray.Add($xml) > $null
            }
        }
    }

    if(!$output){return $xmlArray}
    else{Exit}
}