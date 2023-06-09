Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Make Forms
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "SimpleXPlorer"
$Form.Size = New-Object System.Drawing.Size(800, 600)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false

# Make Tree Folder View
$TreeView = New-Object System.Windows.Forms.TreeView
$TreeView.Location = New-Object System.Drawing.Point(10, 10)
$TreeView.Size = New-Object System.Drawing.Size(200, 550)

# Make List File View
$ListView = New-Object System.Windows.Forms.ListView
$ListView.Location = New-Object System.Drawing.Point(220, 10)
$ListView.Size = New-Object System.Drawing.Size(560, 550)
$ListView.View = "Details"
$ListView.FullRowSelect = $true
# $ListView.Columns.Add("Type", 100)
$ListView.Columns.Add("Name", 200)
$ListView.Columns.Add("Size(Byte)", 100)
$ListView.Columns.Add("Modification Date", 250)

# Make Root-Node
$RootPath = ${env:SystemDrive} + "\"
$RootNode = $TreeView.Nodes.Add($RootPath)
$RootNode.Tag = $RootPath

# Get Folder and Files
$items = Get-ChildItem -Path $RootPath

foreach ($item in $items) {
    if ($item.PSIsContainer) { # Folder
        $folderNode = $RootNode.Nodes.Add($item.Name)
        $folderNode.Tag = $item.FullName
    }
    else{ # (List View) :: Files
        $listViewItem = New-Object System.Windows.Forms.ListViewItem($item.Name)
        $listViewItem.SubItems.Add($item.Length)
        $listViewItem.SubItems.Add($item.LastWriteTime.ToString()) 
        $ListView.Items.Add($listViewItem) > $null
    }
}


<# Event Handler #>
# [Double-Click] Tree View (folder Node)
<#
$TreeView.add_NodeMouseDoubleClick({
    param($sender, $e)

    Write-Host "Double Click !!"

    $selectedNode = $e.Node
    $selectedPath = $selectedNode.Tag


    if ($selectedPath -ne $null) {

        # Reload List
        $items = Get-ChildItem -Path $selectedPath

        $ListView.Items.Clear()

        foreach ($item in $items) {
            if ($item.PSIsContainer) {
                # Folder
                $folderNode = $selectedNode.Nodes.Add($item.Name)
                $folderNode.Tag = $item.FullName
            } else {
                # File
                $listViewItem = New-Object System.Windows.Forms.ListViewItem($item.Name)
                $listViewItem.SubItems.Add("File")
                $listViewItem.SubItems.Add($item.Length)
                $listViewItem.SubItems.Add($item.LastWriteTime.ToString()) 
                $ListView.Items.Add($listViewItem) > $null
            }
        }
    }
})
#>

$TreeView.add_NodeMouseClick({
    param($sender, $e)

    $selectedNode = $e.Node
    $selectedPath = $selectedNode.Tag
    # Write-Host "Single Click ! $selectedNode $selectedPath"
    $ListView.Items.Clear()

    if ($selectedPath -ne $null) {

        # Reload List
        $items = Get-ChildItem -Path $selectedPath

        $ListView.Items.Clear()

        foreach ($item in $items) {
            if ($item.PSIsContainer) {
                # Folder
                $folderNode = $selectedNode.Nodes.Add($item.Name)
                $folderNode.Tag = $item.FullName
            } else {
                # File
                $listViewItem = New-Object System.Windows.Forms.ListViewItem($item.Name)
                $listViewItem.SubItems.Add("File")
                $listViewItem.SubItems.Add($item.Length)
                $listViewItem.SubItems.Add($item.LastWriteTime.ToString()) 
                $ListView.Items.Add($listViewItem) > $null
            }
        }
    }

})


# Add Controls to Forms
$Form.Controls.Add($TreeView)
$Form.Controls.Add($ListView)

# Show Forms
[void]$Form.ShowDialog()

