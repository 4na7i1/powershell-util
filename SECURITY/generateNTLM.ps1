Param([parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$plainPasswd)

function ConvertTo-NTHash {
    Param ([string] $Passwd)
    $ntHash = New-Object byte[] 16
    $unicodePassword = New-Object Win32+UNICODE_STRING $Passwd
    try {
        [Win32]::RtlCalculateNtOwfPassword([ref] $unicodePassword, $ntHash) > $null
    }
    finally {
        <#Do this after the try block regardless of whether an exception occurred or not#>
        $unicodePassword.Dispose()
    }
    # return (($ntHash | ForEach-Object ToString X2) -join '')
    return ([System.BitConverter]::ToString($ntHash) -replace '-','')
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("advapi32.dll", SetLastError = true, EntryPoint = "SystemFunction007", CharSet = CharSet.Unicode)]
    public static extern int RtlCalculateNtOwfPassword(ref UNICODE_STRING password, [MarshalAs(UnmanagedType.LPArray)] byte[] hash);
    [StructLayout(LayoutKind.Sequential)]
    public struct UNICODE_STRING : IDisposable {
        public ushort Length;
        public ushort MaximumLength;
        public IntPtr buffer;
        public UNICODE_STRING(string s) {
            Length = (ushort)(s.Length * 2);
            MaximumLength = (ushort)(Length + 2);
            buffer = Marshal.StringToHGlobalUni(s);
        }
        public void Dispose() {
            if (buffer != IntPtr.Zero) {
                Marshal.FreeHGlobal(buffer);
                buffer = IntPtr.Zero;
            }
        }
    
    }
}
"@

ConvertTo-NTHash $plainPasswd