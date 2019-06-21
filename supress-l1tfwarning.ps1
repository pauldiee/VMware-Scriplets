Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

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
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}