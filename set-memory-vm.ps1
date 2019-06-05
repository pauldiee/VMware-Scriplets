$offlinevms = (Get-VMHost "srv-mtw-esxw-41*" | Get-VM | Where-Object {$_.PowerState -eq "PoweredOff"})

foreach ($vm in $offlinevms){
    Set-VM -VM $vm -MemoryGB 7 -Confirm:$false | Out-Null
    Write-Host $vm set to 7GB Memory -ForegroundColor Green
}