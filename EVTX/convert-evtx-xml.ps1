[CmdletBinding()]param([switch]$overwrite,[Alias("PSPath")][string[]]$basePath)

# Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
# used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
# enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
# characters as escape sequences.

if ($basePath) {
    $evtxFiles = Get-ChildItem -LiteralPath $basePath -Filter "*.evtx" -Recurse
}
else{
    $evtxFiles = Get-ChildItem -Path ./ -Filter "*.evtx" -Recurse
}
# param($evtxFile)

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