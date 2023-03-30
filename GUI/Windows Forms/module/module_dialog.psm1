function Open-fileDialog {
    param ($temp)
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
        # Write-Output ("[Select]: " + $dialog.FileName)
        return $dialog.FileName
    } else {
        # Write-Output ("Cancel.")
        retrurn -1
    }
}

function Open-folderDialog {
    param ()
    Add-Type -AssemblyName System.Windows.Forms

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ 
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Description = 'Select the directory that you want to use as the default.'
        ShowHiddenFiles = $true
        ShowNewFolderButton = $true
    }

    $result = $dialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # Write-Output ("[Select]: " + $dialog.SelectedPath)
        return $dialog.SelectedPath
    } else {
        # Write-Output ("Cancel.")
        return -1
    }
}

function Open-inputDialog {
    param ($OptionalParameters)
    Add-Type -AssemblyName System.Windows.Forms

    # Form
    $Form = New-Object System.Windows.Forms.Form 
    $Form.Size = New-Object System.Drawing.Size(400,130) 
    # $Form.icon
    $Form.Text = "[Form01]"

    # TextNpx
    $textBox = New-Object System.Windows.Forms.textBox
    $textBox.Location = New-Object System.Drawing.Point(20,30)
    $textBox.Size = New-Object System.Drawing.Size(300,20)
    $Form.Controls.Add($textBox)

    # OK Button
    $ButtonOK = New-Object System.Windows.Forms.Button
    $ButtonOK.Location =  New-Object System.Drawing.Point(230,60)
    $ButtonOK.Size = New-Object System.Drawing.Size(60,20)
    $ButtonOK.Text = "OK"
    $Form.Controls.Add($ButtonOK)
    # OK Button Work
    $ButtonOK.add_click{
        if($textBox.text -eq ""){# if Blank
            $textBox.BackColor = "yellow"
        }else{
            $Form.DialogResult = "OK"
        }
    }

    # Cancel Button
    $ButtonCancel = New-Object System.Windows.Forms.Button
    $ButtonCancel.Location =  New-Object System.Drawing.Point(300,60)
    $ButtonCancel.Size = New-Object System.Drawing.Size(60,20)
    $ButtonCancel.Text = "Cancel"
    $ButtonCancel.DialogResult = "Cancel"
    $Form.Controls.Add($ButtonCancel)


    # Show Dialog
    $FormResult = $Form.ShowDialog()

    if($FormResult -eq "OK"){
        # $text = $textBox.Text
        # Write-Output $textBox
        return $textBox.Text
    } else {
        EXIT 
    }
}