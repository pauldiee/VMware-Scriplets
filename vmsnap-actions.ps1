$vCenter = Read-Host -prompt 'Enter FQDN / IP address of vCenter'
Write-Host 'vCenter:' $vCenter ''

# Connect to vCenter with $vCenter variable value
Connect-VIServer -Server $vCenter -Force

#Ask for remove or create snapshot
$snapaction = Read-Host "do you want to remove or create snapshots? (remove/create)"

#Select vm's
$vmtosnapaction = Get-VM | Out-GridView -Title "Select VM's" -OutputMode Multiple

if($snapaction -eq "create"){
    #create snapshot for all selected vm's
    foreach ($vm in $vmtosnapaction){
        New-Snapshot $vm -Name 'AutoSnap' -Description (get-date) -Confirm:$false -RunAsync | Out-Null
    }
}else{
    #remove snapshot for all selected vm's
    foreach ($vm in $vmtosnapaction){
        $vmsnap = Get-VM $vm | Get-Snapshot
        $vmsnap | Remove-Snapshot -Confirm:$false -RunAsync | Out-Null
    }
}

# Get VM snapshot information and output in table format  
foreach ($vm in $vmtosnapaction){
    Get-VM $vm | Get-Snapshot | sort SizeGB -descending | FT VM, Name, Created, @{Label="Size";Expression={"{0:N2} GB" -f ($_.SizeGB)}}, Description
}

# Close connection to active vCenter
Disconnect-VIServer $vCenter -Confirm:$false
Write-Host 'Connection closed to' $vCenter