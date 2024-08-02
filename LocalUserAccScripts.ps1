#$ErrorActionPreference = "SilentlyContinue"
#$DebugPreference = "SilentlyContinue"

Function  Convert-UserFlag {

    Param  ($UserFlag)
  
    $List  = New-Object  System.Collections.ArrayList
  
    Switch  ($UserFlag) {
    
    ($UserFlag  -BOR 0x0002)  {[void]$List.Add('ACCOUNTDISABLE')}

    ($UserFlag  -BOR 0x0200)  {[void]$List.Add('NORMAL_ACCOUNT')}
  
  #  ($UserFlag  -BOR 0x0001)  {[void]$List.Add('SCRIPT')}
  
   
  
   # ($UserFlag  -BOR 0x0008)  {[void]$List.Add('HOMEDIR_REQUIRED')}
  
    ($UserFlag  -BOR 0x0010)  {[void]$List.Add('LOCKOUT')}
  
   # ($UserFlag  -BOR 0x0020)  {[void]$List.Add('PASSWD_NOTREQD')}
  
   # ($UserFlag  -BOR 0x0040)  {[void]$List.Add('PASSWD_CANT_CHANGE')}
  
 <# ($UserFlag  -BOR 0x0080)  {[void]$List.Add('ENCRYPTED_TEXT_PWD_ALLOWED')}
  
    ($UserFlag  -BOR 0x0100)  {[void]$List.Add('TEMP_DUPLICATE_ACCOUNT')}
  
    
  
    ($UserFlag  -BOR 0x0800)  {[void]$List.Add('INTERDOMAIN_TRUST_ACCOUNT')}
  
    ($UserFlag  -BOR 0x1000)  {[void]$List.Add('WORKSTATION_TRUST_ACCOUNT')}
  
    ($UserFlag  -BOR 0x2000)  {[void]$List.Add('SERVER_TRUST_ACCOUNT')}
  
    ($UserFlag  -BOR 0x10000)  {[void]$List.Add('DONT_EXPIRE_PASSWORD')}
  
    ($UserFlag  -BOR 0x20000)  {[void]$List.Add('MNS_LOGON_ACCOUNT')}
  
    ($UserFlag  -BOR 0x40000)  {[void]$List.Add('SMARTCARD_REQUIRED')}
  
    ($UserFlag  -BOR 0x80000)  {[void]$List.Add('TRUSTED_FOR_DELEGATION')}
  
    ($UserFlag  -BOR 0x100000)  {[void]$List.Add('NOT_DELEGATED')}
  
    ($UserFlag  -BOR 0x200000)  {[void]$List.Add('USE_DES_KEY_ONLY')}
  
    ($UserFlag  -BOR 0x400000)  {[void]$List.Add('DONT_REQ_PREAUTH')}
    #>
  
    ($UserFlag  -BOR 0x800000)  {[void]$List.Add('PASSWORD_EXPIRED')}
  
   # ($UserFlag  -BOR 0x1000000)  {[void]$List.Add('TRUSTED_TO_AUTH_FOR_DELEGATION')}
  
  #  ($UserFlag  -BOR 0x04000000)  {[void]$List.Add('PARTIAL_SECRETS_ACCOUNT')}
  
    }
    $List -join ', '
}

$ComputerName = $env:ComputerName
$adsi = [ADSI]"WinNT://$Computername"
$today = [datetime]::now
$Users = $adsi.Children | Where-Object {$_.SchemaClassName -eq 'user'}
$now = Get-Date

$output = foreach ($u in $Users)
{
    $UserName = $u.Name[0] 
    $UserFlags = Convert-UserFlag -UserFlag $u.UserFlags[0]
    $LastLogin = if ($u.LastLogin[0] -is [datetime]){$u.LastLogin[0]}else{'Never logged on'}
    #$PasswordAge = [math]::Round($u.PasswordAge[0]/86400)
    $PasswordLastSet = ($now).AddSeconds(-$u.PasswordAge[0])
    Write-host $PasswordLastSet
    if ($u.LastLogin[0] -is [datetime]) {
        $day_elapsed = New-TimeSpan -Start $LastLogin -End $today
    }
    else {
        $day_elapsed = New-TimeSpan -Days 999

    }
           
        New-Object -TypeName PSObject -Property @{
         Accountname = $UserName
         DaysSinceLastLogin = $day_elapsed.Days
         PasswordLastSet = $PasswordLastSet
         Userflag = $UserFlags
             } | Select-Object Accountname,PasswordLastSet, DaysSinceLastLogin, Userflag
     
         

}
$Destination = "$env:temp\ADUser_$ComputerName.csv"
$Output | Export-Csv InactiveLocalAccounts_$ComputerName.csv -NoTypeInformation -Force
Move-Item "InactiveLocalAccounts_$ComputerName.csv" -Destination $Destination -Force
#aws s3 cp $Destination s3://`

Remove-Item $Destination
