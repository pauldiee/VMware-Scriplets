disconnect-viserver -Server * -Confirm:$false
$sourceVC = Connect-VIServer -Server vcp01.vineta.nl -User aa_paul@meandermc.vineta.nl
$targetVC = Connect-VIServer -Server srv-vcar-03.vineta.nl -User aa_paul@meandermc.vineta.nl

####EXCHANGE TO HYPERFLEX####
$vmhost = "srv-mtw-esxh-06.vineta.nl"
$vm = Get-VM -Server $sourceVC "exc01"
$networkAdapter = Get-NetworkAdapter -VM $vm -Server $sourceVC
$switchname = "HX-DVS-MTW_N"
$destinationPortGroup = Get-VDPortgroup -VDSwitch $switchname -Name "Prod-Backend_N" -Server $targetVC
$datastore = "HXAFF-DS-MTW"
Move-VM -VM $vm -VMotionPriority High -Destination (Get-VMhost -Server $targetVC -Name $vmhost) -Datastore (Get-Datastore -Server $targetVC -Name $datastore) -NetworkAdapter $networkAdapter -PortGroup $destinationPortGroup -runasync

$vmhost = "srv-mtw-esxh-06.vineta.nl"
$vm = Get-VM -Server $sourceVC "exc02"
$networkAdapter = Get-NetworkAdapter -VM $vm -Server $sourceVC
$switchname = "HX-DVS-MTW_N"
$destinationPortGroup = Get-VDPortgroup -VDSwitch $switchname -Name "Prod-Backend_N" -Server $targetVC
$datastore = "HXAFF-DS-MTW"
Move-VM -VM $vm -VMotionPriority High -Destination (Get-VMhost -Server $targetVC -Name $vmhost) -Datastore (Get-Datastore -Server $targetVC -Name $datastore) -NetworkAdapter $networkAdapter -PortGroup $destinationPortGroup -runasync

$vmhost = "srv-mtw-esxh-06.vineta.nl"
$vm = Get-VM -Server $sourceVC "exc03"
$networkAdapter = Get-NetworkAdapter -VM $vm -Server $sourceVC
$switchname = "HX-DVS-MTW_N"
$destinationPortGroup = Get-VDPortgroup -VDSwitch $switchname -Name "Prod-Backend_N" -Server $targetVC
$datastore = "HXAFF-DS-MTW"
Move-VM -VM $vm -VMotionPriority High -Destination (Get-VMhost -Server $targetVC -Name $vmhost) -Datastore (Get-Datastore -Server $targetVC -Name $datastore) -NetworkAdapter $networkAdapter -PortGroup $destinationPortGroup -runasync
####EXCHANGE TO HYPERFLEX####