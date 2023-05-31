<#
 # input:SYSTEM file ---> output:bootkey(syskey)
 # - V.Test
 # - Without performance considerations
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_})]
    [string]$systemFilePath
)


function int8ToUtf8{
    param($int8)
    $byteArray = [byte[]]($int8) # int8 to byte[]
    # $byteArray = $int8.Split() | ForEach-Object { [byte]$_ } 
    # $byteArray = $s.Split() | ForEach-Object { [Convert]::ToByte($_, 16) }
    $utf8String = [System.Text.Encoding]::UTF8.GetString($byteArray) #byte[] -> utf8String

    return $utf8String
}

function Utf8ToInt8 {
    param($utf8String)
    $byteArray = [System.Text.Encoding]::UTF8.GetBytes($utf8String) # utf8String -> byte[]
    $int8 = [System.BitConverter]::ToInt8($byteArray, 0) # byte[] -> int8
    
    return $int8
}

function Seek-key {
    param ($fileStream,$matchIndex)
    $offset = $matchIndex + 12
    $offsetLength = 15
    $fileStream.Seek($offset, [System.IO.SeekOrigin]::Begin) > $null
    $binaryReader = New-Object System.IO.BinaryReader($fileStream)
    
    return $binaryReader.ReadBytes($offsetLength)
}

function Get-BootKey{
    
    param ($foundStrings)
    $p = @(0x8, 0x5, 0x4, 0x2, 0xb, 0x9, 0xd, 0x3, 0x0, 0x6, 0x1, 0xc, 0xe, 0xa, 0xf, 0x7)
    # $tempKey = -join $foundStrings["JD"],$foundStrings["Skew1"],$foundStrings["GBG"],$foundStrings["Data"] ""
    $tempKey = ($foundStrings["JD"], $foundStrings["Skew1"], $foundStrings["GBG"], $foundStrings["Data"]) -join " "
    Write-Debug "[+]$tempKey"

    $byteArray = @()
    for($i=0;$i -lt $tempKey.Length; $i+=4){
        $s = $tempKey[$i]+$tempKey[$($i+2)]
        $byteValue = [Convert]::ToByte($s,16)
        $byteArray += $byteValue
        # Write-Host "Byte value: $byteValue"
    }

    $Bootkey = [byte[]]::new(0)
    foreach ($i in 0..($byteArray.Length - 1)) {# Scramble
        $Bootkey += $byteArray[$p[$i]]
    }
    return $Bootkey
}

<# MAIN #>

try{
    $searchStrings = @("Data", "GBG", "JD", "Skew1")
    $matchIndex = $null
    
    $fileStream = [System.IO.File]::Open($systemFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
    $bufferSize = 4096
    $buffer = New-Object byte[] $bufferSize
    
    $foundDenySavedCredentials = $false
    $matchIndexOffset = 0
    
    while (-not $foundDenySavedCredentials -and $fileStream.Position -lt $fileStream.Length) {
        $bytesRead = $fileStream.Read($buffer, 0, $bufferSize)
    
        for ($i = 0; $i -lt $bytesRead; $i++) {
            $denySavedCredentialsString = [System.Text.Encoding]::ASCII.GetString($buffer[$i..($i+20)])
            if ($denySavedCredentialsString -eq "DenySavedCredentials?") {
                Write-Debug "[+]Found : DenySavedCredentials?"
                $foundDenySavedCredentials = $true
                $matchIndexOffset = $fileStream.Position - $bytesRead + $i + 20
                break
            }
        }
    }
    
    if ($foundDenySavedCredentials) {
        $foundStrings = @{}
    
        foreach ($searchString in $searchStrings) {
            $found = $false
            $fileStream.Position = $matchIndexOffset
    
            while (-not $found -and $fileStream.Position -lt $fileStream.Length) {
                $bytesRead = $fileStream.Read($buffer, 0, $bufferSize)
    
                for ($i = 0; $i -lt $bytesRead - $searchString.Length + 1; $i++) {
                    $match = $true
    
                    for ($j = 0; $j -lt $searchString.Length; $j++) {
                        if ($buffer[$i + $j] -ne [byte]$searchString[$j]) {
                            $match = $false
                            break
                        }
                    }
    
                    if ($match) {
                        $found = $true
                        $matchIndex = $fileStream.Position - $bytesRead + $i
                        break
                    }
                }
    
                if ($found) {
                    break
                }
    
                $fileStream.Position -= $searchString.Length - 1
            }
    
            if ($found) {
                $foundStrings[$searchString] = $matchIndex
            }
        }
    
        if ($foundStrings.Count -gt 0) {
            Write-Host "[+]Found"
            foreach ($entry in $foundStrings.GetEnumerator() | Sort-Object -Property Value) {
                Write-Host "[I]Key: $($entry.Key), Index: $($entry.Value)"
                $rtn = Seek-Key $fileStream $($entry.Value)
                $foundStrings[$($entry.Key)] = (int8ToUtf8 $rtn) #$rtn
            }
            foreach ($entry in $foundStrings.GetEnumerator()){
                Write-Host "[I]Key: $($entry.Key), Key-Fragment: $($entry.Value)"
            }
            $bootKey = Get-BootKey $foundStrings
            Write-Host "[+]BootKey : $bootKey"
        } else {
            Write-Host "[E]Not Found (Possibility of file corruption)"
        }
    } else {
        Write-Host "[E]DenySavedCredentials? is Not Found (Possibility of file corruption)"
    }
    
    
}
finally{
    $fileStream.Close()
    Write-Debug "[-]File-Stream Close"
}