function firstLine{
    param()
    Write-Output "┌$("─" * ($host.UI.RawUI.WindowSize.Width-2))┐"
}

function endLine {
    param ()
    Write-Output "└$("─" * ($host.UI.RawUI.WindowSize.Width-2))┘"
}

function middleLine{
    param($contents)
    $contents = $contents -replace "`r?`n", "" 
    if($null -eq $contents){
        $contents = "│"+(" " * ($host.UI.RawUI.WindowSize.Width-2))+"│"
    }
    else{
        if($contents.Length -gt $host.UI.RawUI.WindowSize.Width-2){#Split one line
            $splitNumber = [math]::Floor($contents.Length/($host.UI.RawUI.WindowSize.Width-2))
            $residual = $contents.Length%($host.UI.RawUI.WindowSize.Width-2)
            for ($i = 0; $i -lt $splitNumber; $i++) {
                # $i
                $content = $contents.Substring($i*($host.UI.RawUI.WindowSize.Width-2),$host.UI.RawUI.WindowSize.Width-2)
                $content = "│"+$content + (" " * ($host.UI.RawUI.WindowSize.Width-(2+$content.Length)))+"│"
                Write-Output $content
            }
            if($residual){
                $content = $contents.Substring($contents.Length - $residual)
                $content = "│"+$content + (" " * ($host.UI.RawUI.WindowSize.Width-(2+$content.Length)))+"│"
                Write-Output $content
            }
            $isFlag = $true
        }
        else{
            $contents = "│"+$contents + (" " * ($host.UI.RawUI.WindowSize.Width-(2+$contents.Length)))+"│"
        }
    }
    if(!$isFlag){
        Write-Host $contents
    }
}