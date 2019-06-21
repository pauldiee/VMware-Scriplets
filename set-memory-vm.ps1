Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

while (Get-VM "VD071*" | Where-object {$_.powerstate -eq "poweredon"}) { 
    $offlinevms = (Get-VM "VD071*"| Where-Object {$_.PowerState -eq "PoweredOff"})
    foreach ($vm in $offlinevms){
        if ((get-vm $vm |Where-Object {$_.MemoryGB -eq "8"})){
            Set-VM -VM $vm -MemoryGB 7 -Confirm:$false | Out-Null
            Write-Host $vm set to 7GB Memory -ForegroundColor Green
        } else{
        Write-Host $vm already set to 7GB Memory -ForegroundColor Cyan
        }
    }    
Start-Sleep -s 60
}
$offlinevms = (Get-VM "VD071*"| Where-Object {$_.PowerState -eq "PoweredOff"})
foreach ($vm in $offlinevms){
    if ((get-vm $vm |Where-Object {$_.MemoryGB -eq "8"})){
        Set-VM -VM $vm -MemoryGB 7 -Confirm:$false | Out-Null
        Write-Host $vm set to 7GB Memory -ForegroundColor Green
    } else{
    Write-Host $vm already set to 7GB Memory -ForegroundColor Cyan
    }
}
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}