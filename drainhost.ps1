#CAM IT solutions Edwin de Bruin
#Drain VDI Server and reboot host, wait to come back online


$ESXhost=""
$Domainname=""
$CitrixDC=""
$vcenterservers=@( 
    "", 
    ""
);

# VMware modules
get-module -ListAvailable | where-Object -Property name -like "*vmware*" | Import-Module
# Citrix modules
add-PSSnapin Citrix*
# Modules file

# Disconnect-VIServer -Force -Confirm:$false
Connect-VIServer $vcenterservers

$vmhostFQDN= $esxhost+"."+$Domainname
#set poweredoff vm's in maintenance mode in Citrix
$VMSpoweredOff= Get-VMhost $vmhostFQDN | Get-VM | Where-object {$_.powerstate -eq "poweredoff"}
     foreach ($name in $VMSpoweredOff) {
                        $CitrixState=Get-BrokerDesktop -HostedMachineName $name -AdminAddress $CitrixDC
                        Write-Host $name
                        Set-BrokerMachineMaintenanceMode -InputObject $citrixState.MachineName $true
                        Write-Host "Done!" $name -ForegroundColor Green
                        }                                              
       

while (Get-VMhost $vmhostFQDN | Get-VM | Where-object {$_.powerstate -eq "poweredon"}) { 
Clear-host
$VMSpoweredOn= Get-VMhost $vmhostFQDN | Get-VM | Where-object {$_.powerstate -eq "poweredon"}

    foreach ($name in $VMSpoweredOn) {
        $CitrixState = Get-BrokerDesktop -HostedMachineName $name -AdminAddress $CitrixDC
        if ($citrixState.SessionID -ne "-1") {
                        Write-Host $name
                        stop-VM -VM $name -confirm:$false
                        Set-BrokerMachineMaintenanceMode -InputObject $citrixState.MachineName $true
                        Write-Host "Done!" $name -ForegroundColor Green
                        } 
                        else {Write-host -ForegroundColor Cyan "$name has user logged on, skipping this round"}
                        
         }
Write-host -foregroundcolor Yellow "Recharging for next awesoming round of enabling maintenancemode. Waiting 60 sec."
Start-Sleep -s 60
}

#Enable Host maintenance

Set-VMHost $vmhostFQDN -state Maintenance -Confirm:$false
Write-Host "Enabled Maintenance mode on $ESXhost" -ForegroundColor Magenta

#reboot host
write-host "trying to reboot $ESXhost"
while (Get-VMHost $vmhostFQDN | Where-Object {$_.ConnectionState -eq "Connected"}){ 
write-host "hold your horses!! $ESXhost still not in maintenance mode, chill 20 seconds brah" -ForegroundColor Red
Start-Sleep -s 20
}
Restart-VMHost $vmhostFQDN -Confirm:$false

#wait for host to come back online

while (Get-VMHost $vmhostFQDN | Where-Object {$_.ConnectionState -ne "Connected"}){ 
write-host "Host not online, Lets wait another minute" -ForegroundColor Red
Start-Sleep -s 60
}

#disable maintenance mode of vm's in  in Citrix
$VMSonhost= Get-VMhost $vmhostFQDN | Get-VM
     foreach ($name in $VMSonhost) {
                        $CitrixState=Get-BrokerDesktop -HostedMachineName $name -AdminAddress $CitrixDC
                        Write-Host $name
                        Set-BrokerMachineMaintenanceMode -InputObject $citrixState.MachineName $false
                        Write-Host "Done!" $name -ForegroundColor Green
                        }   

Write-host "Its done!"

#Disconnect-VIServer -Force -Confirm:$false 
