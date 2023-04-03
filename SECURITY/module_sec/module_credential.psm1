function Get-CredentialJSON {
    param()
    <# Create Credential File (.txt,.JSON) #>
    $machineList = New-Object System.Collections.ArrayList

    class Events {
        <# Parameter #>
        $machine;$user;$secpasswd;$credential
        
        <# Setup Credential #>
        Events($machineName,$userName,$passwd){
            $this.machine = $machineName
            $this.user = $userName
            if($passwd.GetType().Name -eq "SecureString"){$this.secpasswd = $passwd}
            else{$this.secpasswd = ConvertTo-SecureString $passwd -AsPlainText -Force}
            $this.credential = New-Object System.Management.Automation.PSCredential ($userName, $this.secpasswd)
        }
    }

    <# Create Credential #> #[need improvement] => use parameters? or ?
    $secPasswd = (Get-Credential -User dummy\ -Message "Password").Password
    $machineList.Add([Events]::new("TM01","user01",$secPasswd)) > $null
    $machineList.Add([Events]::new("TM02","user02",$secPasswd)) > $null
    $machineList.Add([Events]::new("TM03","user03",$secPasswd)) > $null
    $machineList.Add([Events]::new("TM05","user05",$secPasswd)) > $null

    $machineList | Select-Object machine,user,@{Name="secpasswd";Expression = { $_.secpasswd | ConvertFrom-SecureString }}| ConvertTo-Json | Set-Content "./credential_$(Get-Date -Format 'yyyy-MMdd-HHmmss').json"

}

function Get-PlainPasswd {
    param ($securePass)
    
    # CREATE Dummy Credential
    $Credential = New-Object System.Management.Automation.PSCredential \"dummy\", $securePass
    # GET plain-passwd
    $plainPass = $Credential.GetNetworkCredential().Password

    return $plainPass
}

function Read-CredentialJSON{
    param([parameter(mandatory=$true)][String]$crFilePath)
    # var 
    $machineList = New-Object System.Collections.ArrayList
    # GET Password File Contents
    $data = Get-Content $crFilePath | ConvertFrom-Json

    foreach ($d in $data){
        # GET Secure-passwd
        $SecurePassWord = $d.secpasswd | ConvertTo-SecureString
        # GET palin-passwd
        $plainPass = Get-PlainPasswd -securePass $SecurePassWord
        $machine = $d.machine
        $user = $d.user
        $machineList.Add([pscustomObject]@{
            machine=$machine
            user=$user
            plainpass=$plainPass
        }) > $null
    }
    return $machineList
}