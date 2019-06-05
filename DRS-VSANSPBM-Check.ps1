

$vcenter = ""

Connect-VIServer $vcenter -Force

$DC1VMs = ""
$DC2VMs = ""
$DC1VMs = (Get-SpbmStoragePolicy -Name "CC|Resources – Geen DC Failover – RAID5 – DC1" | Get-VM | Sort-Object Name)
$DC2VMs = (Get-SpbmStoragePolicy -Name "CC|Resources – Geen DC Failover – RAID5 – DC2" | Get-VM | Sort-Object Name)

$MER1SHOULDRUNVMs = ""
$MER2SHOULDRUNVMs = ""
$MER1SHOULDRUNVMs = (Get-DrsClusterGroup -Name "Should Run MER 1" | Select-Object -ExpandProperty Member)
$MER2SHOULDRUNVMs = (Get-DrsClusterGroup -Name "Should Run MER 2" | Select-Object -ExpandProperty Member)

$addtogroupdc1 = (Compare-Object -ReferenceObject $MER1SHOULDRUNVMs -DifferenceObject $DC1VMs | Where-Object {$_.SideIndicator -eq "=>"})
$addtogroupdc1 = (Compare-Object -ReferenceObject $MER2SHOULDRUNVMs -DifferenceObject $DC2VMs | Where-Object {$_.SideIndicator -eq "=>"})

Get-DrsClusterGroup -Name "Should Run MER 1" | Set-DrsClusterGroup -VM $addtogroupdc1 -Add
Get-DrsClusterGroup -Name "Should Run MER 2" | Set-DrsClusterGroup -VM $addtogroupdc2 -Add