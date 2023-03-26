# [Parameter(Position=0,ParameterSetName="LiteralPath")][Alias("PSPath")][string[]]$LiteralPath
$isAdmin = $false
$resultTemp = "result.tmp"

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")){ 
    # $sqFile = "$(Get-Location)\Client_offline.xml"
    # Write-Output "No Administrators"
    $setFolder = (Get-Location).Path
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -WorkingDirectory `"$setFolder`"" -Verb RunAs -Wait
    $resultFile = Join-Path $setFolder $resultTemp
    Get-Content $resultFile
    Remove-Item $resultFile > $null
    exit
}
else{
    # Write-Output "Administrators"
    $isAdmin = $true
}


$Date = Get-Date -Format "yyyy-MMdd-HHmmss"

$path = $PSCommandPath
    
foreach($p in $path.Split("\")){
    if($null -eq $newPath){
        $newPath += $p
    }
    else{
        if($p -ne $path.Split("\")[-1]){
            $newPath = Join-Path -Path $newPath -ChildPath $p
        }
    }

}

$sqFile = Join-Path -Path $newPath -ChildPath Client_Offline.xml
$xml = Join-Path -Path $newPath -ChildPath "$Date.xml"
$resultFile = Join-Path -Path $newPath -ChildPath $resultTemp

wevtutil qe $sqFile /sq:true /f:XML /rd:false /e:root > $xml

$stream = [System.IO.StreamReader]::new($xml)
$tXML = [XML]($stream).ReadToEnd()

try {
    if($null -eq $tXML.root.Event){
        # Write-Output "No Events."
        "No Events." > $resultFile
    }

    :label01 foreach ($evt in $tXML.root.Event) {
        $DateTime = [datetime]$evt.System.TimeCreated.GetAttribute("SystemTime")
        $EventID=$evt.System.EventID
    
        if($EventID -eq 4624){# logon to this machine
            # $ActivityID = $evt.System.Correlation.GetAttribute("ActivityID")
            foreach($data in $evt.EventData.Data){
                if($data.Name -eq "LogonType"){$logonType=$data."#text"}
                elseif($data.Name -eq "ProcessName"){$NewProcessName=$data."#text"}
                elseif($data.Name -eq "IpAddress"){$Ip=$data."#text"}
                elseif($data.Name -eq "IpPort"){$IpPort=$data."#text"}
                elseif($data.Name -eq "SubjectLogonId"){$logonid_s=$data."#text"}
                elseif($data.Name -eq "WorkstationName") {$fromDom=$data."#text"}#from
                elseif($data.Name -eq "TargetLogonId"){$logonid_t=$data."#text"}
                elseif($data.Name -eq "TargetUserName") {$toUser=$data."#text"}#to
                elseif($data.Name -eq "TargetDomainName") {$toDom=$data."#text"}#to
                elseif($data.Name -eq "TargetLinkedLogonId"){$logonid_l=$data."#text"}
            }
            Write-Output "'Logon' $DateTime $fromDom ($Ip : $IpPort)"
            # "'Logon' $DateTime $fromDom ($Ip : $IpPort)" > $resultFile
            Add-Content -Path $resultFile "'Logon' $DateTime $fromDom ($Ip : $IpPort)" 
        }
        elseif($EventID -eq 4625){#Logon to this machine (Failed)
            $fromUser = ($evt.EventData.Data[5])."#text"
            $fromDom = ($evt.EventData.Data[6])."#text"
            $subStatus = ($evt.EventData.Data[9])."#text"
            $logonType = ($evt.EventData.Data[10])."#text"
            $Ip = ($evt.EventData.Data[-2])."#text"
            $IpPort = ($evt.EventData.Data[-1])."#text"
    
            Write-Output "'Logon(Failed)' $Datetime ($logonType)-[$subStatus] $fromDom/$fromUser ($Ip : $ipPort)"
            # "'Logon(Failed)' $Datetime ($logonType)-[$subStatus] $fromDom/$fromUser ($Ip : $ipPort)" > $resultFile
            Add-Content -Path $resultFile "'Logon(Failed)' $Datetime ($logonType)-[$subStatus] $fromDom/$fromUser ($Ip : $ipPort)"
        }
    }
}
finally {
    <#Do this after the try block regardless of whether an exception occurred or not#>
    # if($isAdmin){
    #     Get-Content $resultFile
    # }
    
    $stream.Dispose()
}

# Pause



