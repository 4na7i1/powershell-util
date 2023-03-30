[CmdletBinding()]param([switch]$overwrite)

# param($evtxFile)
$evtxFiles = Get-ChildItem -Path ./ -Filter "*.evtx" -Recurse

foreach($evtxFile in $evtxFiles){
    $xmlFile = Join-Path -Path $evtxFile.Directory.FullName -ChildPath ($evtxFile.BaseName + ".xml")
    if(!(Test-Path $xmlFile) -or $overwrite){
        [xml](wevtutil qe $evtxFile /logfile /e:root) > $xmlFile
        Write-Output "Done: $xmlFile"
    }
    else{
        Write-Output "Already Done: $xmlFile"
    }
}