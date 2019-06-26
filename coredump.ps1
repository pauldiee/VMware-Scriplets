$vcenter = ''
Connect-VIServer $vcenter
foreach($vmhost in Get-VMHost){
$esxcli = Get-EsxCli -VMHost $vmhost.Name
$esxcli.system.coredump.network.set($null,"vmk0",$null,$vcenter,6500)
$esxcli.system.coredump.network.set($true)
$esxcli.system.coredump.network.get()
}