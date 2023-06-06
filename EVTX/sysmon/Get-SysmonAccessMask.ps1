<#
 # Example : (1)./get-sysmonaccessMask -AccessMask 0x143a 
 #                    PROCESS_QUERY_INFORMATION
 #                    PROCESS_VM_READ
 #                    PROCESS_QUERY_LIMITED_INFORMATION
 #                    PROCESS_VM_WRITE
 #                    PROCESS_CREATE_THREAD
 #                    PROCESS_VM_OPERATION 
 #
 #           (2)./get-sysmonaccessMask -AccessMask 0x1fffff
 #                  PROCESS_SET_INFORMATION
 #                  PROCESS_QUERY_INFORMATION
 #                  PROCESS_VM_READ
 #                  PROCESS_CREATE_PROCESS
 #                  PROCESS_SET_QUOTA
 #                  SYNCHRONIZE
 #                  PROCESS_TERMINATE
 #                  PROCESS_QUERY_LIMITED_INFORMATION
 #                  PROCESS_SUSPEND_RESUME
 #                  PROCESS_VM_WRITE
 #                  PROCESS_CREATE_THREAD
 #                  PROCESS_DUP_HANDLE
 #                  PROCESS_VM_OPERATION
#>

[CmdletBinding(DefaultParameterSetName='Mask')]
param (
    # Acces mask names.
    [Parameter(Mandatory=$true, ParameterSetName='Access')]
    [ValidateSet("PROCESS_CREATE_PROCESS", "PROCESS_CREATE_THREAD", "PROCESS_DUP_HANDLE", "PROCESS_SET_INFORMATION",
    "PROCESS_SET_QUOTA", "PROCESS_QUERY_LIMITED_INFORMATION", "PROCESS_QUERY_INFORMATION", "PROCESS_SUSPEND_RESUME",
    "PROCESS_TERMINATE", "PROCESS_VM_OPERATION", "PROCESS_VM_READ", "PROCESS_VM_WRITE", "SYNCHRONIZE")]
    [string[]]
    $AccessRight,

    # Access mask 
    [Parameter(Mandatory=$true, ParameterSetName='Mask')]
    [Int32]
    $AccessMask
)

$ProcessPermissions = @{
    "PROCESS_CREATE_PROCESS" = 0x0080
    "PROCESS_CREATE_THREAD" = 0x0002
    "PROCESS_DUP_HANDLE" = 0x0040
    "PROCESS_SET_INFORMATION" = 0x0200
    "PROCESS_SET_QUOTA" = 0x0100
    "PROCESS_QUERY_LIMITED_INFORMATION" = 0x1000
    "PROCESS_QUERY_INFORMATION" = 0x0400
    "PROCESS_SUSPEND_RESUME" = 0x0800
    "PROCESS_TERMINATE" = 0x0001
    "PROCESS_VM_OPERATION" = 0x0008
    "PROCESS_VM_READ" = 0x0010
    "PROCESS_VM_WRITE" = 0x0020
    "SYNCHRONIZE" = 0x00100000
}

switch ($PSCmdlet.ParameterSetName) {
    'Mask' { 
        $maskValues = $ProcessPermissions.Keys | Where-Object { $ProcessPermissions[$_] -band $AccessMask }
        $maskValues 
    }

    'Access' {
        $mask = ($AccessRight | ForEach-Object { $ProcessPermissions[$_] }) -bor 0
        "0x$([Convert]::ToString($mask, 16))"
    }
}
