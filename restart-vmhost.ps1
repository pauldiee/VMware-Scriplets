Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

#Restart ESXi Host
$esxhost = Read-Host "Enter ESXI hostname here"
if (Get-VMHost $esxhost | Where-Object {$_.ConnectionState -eq "Maintenance"}){
    Restart-VMHost $esxhost -Confirm:$false | Out-Null
    Write-Host Restarted $esxhost! -ForegroundColor Green
} else {
    Write-Host $esxhost not in Maintenance Mode. -ForegroundColor Cyan
}
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}