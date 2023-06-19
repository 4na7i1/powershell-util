<#
 # Show BitsTransfer History Information 
 # TEST 
#>
Add-Type -AssemblyName System.Windows.Forms

# Make Form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "BITS Transfer Histrory"
$Form.Size = New-Object System.Drawing.Size(1200, 800)
$Form.StartPosition = "CenterScreen"

# Make DataGridView
$DataGridView = New-Object System.Windows.Forms.DataGridView
$DataGridView.Location = New-Object System.Drawing.Point(10, 10)
$DataGridView.Size = New-Object System.Drawing.Size(1100, 700)
$DataGridView.Anchor = "Top, Left, Bottom, Right"
$DataGridView.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$DataGridView.AllowUserToAddRows = $false
$DataGridView.ReadOnly = $true
$Form.Controls.Add($DataGridView)

# Get BitsTransfer Information
$BitsTransfers = Get-BitsTransfer

# Bind Information to DataTable
$DataTable = New-Object System.Data.DataTable
$DataTable.Columns.Add("JobId", [System.Guid])
$DataTable.Columns.Add("DisplayName", [System.String])
$DataTable.Columns.Add("TransferType", [System.String])
$DataTable.Columns.Add("JobState", [System.String])
$DataTable.Columns.Add("Progress", [System.String])
$DataTable.Columns.Add("RemoteName", [System.String])
$DataTable.Columns.Add("LocalName", [System.String])
$DataTable.Columns.Add("BytesTransferred", [System.Int64])


foreach ($BitsTransfer in $BitsTransfers) {
    $DataRow = $DataTable.NewRow()
    $DataRow["JobId"] = $BitsTransfer.JobId
    $DataRow["DisplayName"] = $BitsTransfer.DisplayName
    $DataRow["TransferType"] = $BitsTransfer.TransferType
    $DataRow["JobState"] = $BitsTransfer.JobState
    $DataRow["Progress"] = $BitsTransfer.Progress
    $DataRow["RemoteName"] = $BitsTransfer.FileList.RemoteName
    $DataRow["LocalName"] = $BitsTransfer.FileList.LocalName
    $DataRow["BytesTransferred"] = $BitsTransfer.BytesTransferred
    $DataTable.Rows.Add($DataRow)
}

$DataGridView.DataSource = $DataTable

# Show
$Form.ShowDialog()
