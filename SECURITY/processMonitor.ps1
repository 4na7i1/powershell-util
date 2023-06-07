<#
 # Simple Process Monitor 
 # (PID,ProcessName,ParentPID,ParentProcessName)
 #>


$IntervalSeconds = 5  # Monitoring Interval
$ProcessHash = @{} # Stores process information in hash table

while ($true) {
    Clear-Host  # Clear Console

    # Get Processes
    $Processes = Get-CimInstance -ClassName Win32_Process

    # reflesh Process information Hash Table
    foreach ($Process in $Processes) {
        $ProcessHash[$Process.ProcessId] = $Process
    }

    # Set ProcessTable
    $ProcessTable = $Processes | Select-Object `
        @{Name = 'PID'; Expression = {$_.ProcessId}}, `
        @{Name = 'ProcessName'; Expression = {$_.Name}}, `
        @{Name = 'Parent PID'; Expression = {$_.ParentProcessId}}, `
        @{
            Name = 'Parent ProcessName'
            Expression = {
                $ParentProcess = $ProcessHash[$_.ParentProcessId]
                if ($ParentProcess) {
                    $ParentProcess.Name
                } else {
                    "N/A"
                }
            }
        } | Format-Table -AutoSize

    $ProcessTable | Format-Table -AutoSize
    # $ProcessTable | Format-Table -AutoSize > "test.txt" Output

    Start-Sleep -Seconds $IntervalSeconds  # Wait Time
}
