Add-Type -AssemblyName System.Windows.Forms

# Form
$Form = New-Object System.Windows.Forms.Form 
$Form.Size = New-Object System.Drawing.Size(400,130) 
$Form.icon
$Form.Text = "[Form01]"

# TextNpx
$TextBox = New-Object System.Windows.Forms.TextBox
$TextBox.Location = New-Object System.Drawing.Point(20,30)
$TextBox.Size = New-Object System.Drawing.Size(300,20)
$Form.Controls.Add($TextBox)

# OK Button
$ButtonOK = New-Object System.Windows.Forms.Button
$ButtonOK.Location =  New-Object System.Drawing.Point(230,60)
$ButtonOK.Size = New-Object System.Drawing.Size(60,20)
$ButtonOK.Text = "OK"
$Form.Controls.Add($ButtonOK)
# OK Button Work
$ButtonOK.add_click{
    if($TextBox.text -eq ""){# if Blank
        $TextBox.BackColor = "yellow"
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

if($FormResult -eq "OK"){# if OK
    $textBox = $TextBox.Text
    Write-Output $textBox
} else {
    EXIT 
}