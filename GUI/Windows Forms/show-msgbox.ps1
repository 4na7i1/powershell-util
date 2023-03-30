function Show-Msgbox([string]$Text,[string]$Caption = "PowerShell",[System.Windows.Forms.MessageBoxButtons]$MessageBoxButtons = [System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]$MessageBoxIcon = [System.Windows.Forms.MessageBoxIcon]::Information,[System.Windows.Forms.MessageBoxDefaultButton]$MessageBoxDefaultButton = [System.Windows.Forms.MessageBoxDefaultButton]::Button2){
    Add-Type -AssemblyName System.Windows.Forms

    [System.Windows.Forms.MessageBox]::Show($Text, $Caption, $MessageBoxButtons, $MessageBoxIcon,$MessageBoxDefaultButton)
}

$dialogResult = Show-Msgbox -Text "Yes or No" -Caption "TEST" -MessageBoxButtons YesNo -MessageBoxIcon Question

Switch ($DialogResult){
    "None"{
        Write-Output "None"
    }
    "OK"{
        Write-Output "OK"
    }
    "Cancel"{
        Write-Output "Cancel"
    }
    "Abort"{
        Write-Output "Abort"
    }
    "Retry"{
        Write-Output "Retry"
    }
    "Ignore"{
        Write-Output "Ignore"
    }
    "Yes"{
        Write-Output "Yes"
    }
    "No"{
        Write-Output "No"
    }
    Default{Write-Error "dialog error."}
}
