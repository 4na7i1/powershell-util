Add-Type -AssemblyName System.Windows.Forms

$dialog = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Description = 'Select the directory that you want to use as the default.'
    ShowHiddenFiles = $true
    ShowNewFolderButton = $true
}

$result = $dialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output ("[Select]: " + $dialog.SelectedPath)
} else {
    Write-Output ("Cancel.")
    EXIT
}