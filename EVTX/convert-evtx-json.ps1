# Convert evtx file to json file
# Example : ./convert-evtx-json -basepath "(folder or evtx file path)"
param([Alias("PSPath")][string[]]$basePath)

# Import Module
Import-Module -Name "..\EVTX\module_evtx\module_evtx.psm1" -Force -Function Convert-EvtxToXML

# evtx -> xml
$events = Convert-EvtxToXML -basePath $basePath

# xml -> json
Write-Output "Evtx -> Json"
$evtxFiles = Get-ChildItem -LiteralPath $basePath -Filter "*.evtx" -Recurse

$i=0
foreach($event in $events){
    $jsonFile = Join-Path -Path $evtxFiles[$i].Directory.FullName -ChildPath ($evtxFiles[$i].BaseName + ".json")
    
    $eventsList = New-Object System.Collections.ArrayList

    foreach($event in ([xml]$event).root.Event){
        # $event.System
        $tmpEvent = [ordered]@{
            System = [ordered]@{}
            EventData = [ordered]@{}
        }
    
        foreach($evtSystem in $event.System.ChildNodes){
            # $evtSystem.LocalName
            
            if($evtSystem.HasAttributes){
                $tmp = [ordered]@{}
                foreach($attribute in $evtSystem.Attributes){
                    $tmp.Add($attribute.LocalName,$attribute."#text")
                }
                # $evtSystem.Attributes.LocalName
                # $evtSystem.Attributes."#text"
                $value = $tmp
            }
            else{
                $value = $evtSystem.InnerText 
            }
    
            $tmpEvent.System.Add($evtSystem.LocalName,$value)
    
        }
        foreach($evtSystem in $event.EventData.Data){
            # [string]$abcd = $evtSystem.Name
            # [string]$abcd2 = $evtSystem."#text"
            # [string]$abcd2 = $evtSystem.InnerText
            # $abcd3 = [pscustomobject]@{ ($abcd) = ($abcd2) }
            $tmpEvent.EventData.Add($evtSystem.Name,$evtSystem.InnerText)
        }
        $eventsList.Add($tmpEvent) > $null    
    }
    
    ConvertTo-Json -InputObject  $eventsList -Depth 100 > $jsonFile
    $i++
}
Write-Output "Done."
