$vcenter = Read-Host "Enter vCenter FQDN here"
Connect-VIServer $vcenter -Force | Out-Null

#Restart ESXi Host
$esxhost = Read-Host "Enter ESXI hostname here"
if (Get-VMHost $esxhost | Where-Object {$_.ConnectionState -eq "Maintenance"}){
    Restart-VMHost $esxhost -Confirm:$false | Out-Null
    Write-Host Restarted $esxhost! -ForegroundColor Green
} else {
    Write-Host $esxhost not in Maintenance Mode. -ForegroundColor Cyan
}
Disconnect-VIServer * -Force -Confirm:$false