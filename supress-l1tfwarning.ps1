$ErrorActionPreference = "SilentlyContinue"
Disconnect-VIServer * -Force -Confirm:$false | Out-Null
$ErrorActionPreference = "Continue"
$vcenter = Read-Host "enter vcenter name"
Connect-VIServer $vcenter".fqdn" -force

#Supress L1TF warning
$allhosts = (Get-Cluster | Get-VMHost | Sort-Object Name)
foreach ($esxi in $allhosts){
    if ((Get-AdvancedSetting -Entity $esxi -Name UserVars.SuppressHyperthreadWarning | Where-Object {$_.Value -eq "1"})){
        Write-Host HyperThreadWarning already Suppressed on $esxi -ForegroundColor Cyan
    } else{
        Get-AdvancedSetting -Entity $esxi -Name UserVars.SuppressHyperthreadWarning | Set-AdvancedSetting -Value 1 -Confirm:$false | Out-Null
        Write-Host HyperThreadWarning Suppressed on $esxi -ForegroundColor Green
    }
}
Disconnect-VIServer * -Force -Confirm:$false | Out-Null