Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

$portgroups = @{}
$portgroups.Add('Prod-VDI-1','784')
$portgroups.Add('Prod-VDI-2','785')
$portgroups.Add('Prod-VDI-3','786')
$portgroups.Add('Prod-VDI-4','787')
$portgroups.Add('Prod-VDI-5','788')
$portgroups.Add('Prod-VDI-6','789')
$portgroups.Add('Prod-VDI-7','790')
$portgroups.Add('Prod-VDI-8','791')
$portgroups.Add('Prod-VDI-9','792')
$portgroups.Add('Prod-VDI-10','793')
$portgroups.Add('Prod-VDI-11','794')
$portgroups.Add('Prod-VDI-12','795')
$portgroups.Add('Prod-VDI-13','796')
$portgroups.Add('Prod-VDI-14','797')

#Create all Portgroups from Table $portgroups
$allhosts = (Get-Cluster | Get-VMHost | Sort-Object Name)
foreach ($portgroup in $portgroups.Keys){
    foreach ($esx in $allhosts){
        if (Get-VMHost $esx | Get-VirtualSwitch -Standard -Name "vSwitch1" | Get-VirtualPortGroup | Where-Object {$_.Name -eq $portgroup}){
            Write-Host Portgroup $portgroup already exists on $esx! -ForegroundColor Cyan
        } else {
            Get-VMHost $esx | Get-VirtualSwitch -Standard -Name "vSwitch1" | New-VirtualPortGroup -Name $portgroup -VLanId $portgroups.$portgroup | Out-Null
            Write-Host Portgroup $portgroup Created on $esx! -ForegroundColor Green
        }
    }
}
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}