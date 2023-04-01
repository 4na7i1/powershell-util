# modularization -> module_evtx.psm1
[CmdletBinding()]param([switch]$overwrite,[Alias("PSPath")][string[]]$basePath)

if ($basePath) {
    $evtxFiles = Get-ChildItem -LiteralPath $basePath -Filter "*.evtx" -Recurse
}
else{
    $evtxFiles = Get-ChildItem -Path ./ -Filter "*.evtx" -Recurse
}

foreach($evtxFile in $evtxFiles){
    $xmlFile = Join-Path -Path $evtxFile.Directory.FullName -ChildPath ($evtxFile.BaseName + ".xml")
    if(!(Test-Path $xmlFile) -or $overwrite){
       (wevtutil qe $evtxFile /logfile /e:root) > $xmlFile
        # $xml.root.Event
        Write-Output "Done: $xmlFile"
    }
    else{
        Write-Output "Already Done: $xmlFile"
    }
}