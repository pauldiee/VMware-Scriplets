$ErrorActionPreference = "SilentlyContinue"
Disconnect-VIServer * -Force -Confirm:$false | Out-Null
$ErrorActionPreference = "Continue"
$vcenter = Read-Host "enter vcenter name"
Connect-VIServer $vcenter".fqdn" -force

#Create Prod-VDI-13 Portgroup
$allhosts = (Get-Cluster | Get-VMHost | Sort-Object Name)
foreach ($esx in $allhosts){
    if (Get-VMHost $esx | Get-VirtualSwitch -Standard -Name "vSwitch1" | Get-VirtualPortGroup | Where-Object {$_.Name -eq "Prod-VDI-13"}){
        Write-Host Portgroup "Prod-VDI-13" already exists on $esx! -ForegroundColor Cyan
    } else {
        Get-VMHost $esx | Get-VirtualSwitch -Standard -Name "vSwitch1" | New-VirtualPortGroup -Name "Prod-VDI-13" -VLanId "796" | Out-Null
        Write-Host Portgroup "Prod-VDI-13" Created on $esx! -ForegroundColor Green
    }
}
#Create Prod-VDI-14 Portgroup
$allhosts = (Get-Cluster | Get-VMHost | Sort-Object Name)
foreach ($esx in $allhosts){
    if (Get-VMHost $esx | Get-VirtualSwitch -Standard -Name "vSwitch1" | Get-VirtualPortGroup | Where-Object {$_.Name -eq "Prod-VDI-14"}){
        Write-Host Portgroup "Prod-VDI-14" already exists on $esx! -ForegroundColor Cyan
    } else {
        Get-VMHost $esx | Get-VirtualSwitch -Standard -Name "vSwitch1" | New-VirtualPortGroup -Name "Prod-VDI-14" -VLanId "797" | Out-Null
        Write-Host Portgroup "Prod-VDI-14" Created on $esx! -ForegroundColor Green
    }
}
Disconnect-VIServer * -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null