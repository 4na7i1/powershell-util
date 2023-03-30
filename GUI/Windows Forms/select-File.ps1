Add-Type -assemblyName System.Windows.Forms 

$dialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    # Filter = "text|*.txt|csv|*.csv|All Files|*.*"
    Title = "Select File"
    Filter = "All Files|*.*"
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
}
 
# $dialog.InitialDirectory = [Environment]::GetFolderPath('Desktop')
$result = $dialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output ("[Select]: " + $dialog.FileName)
} else {
    Write-Output ("Cancel.")
    EXIT
}