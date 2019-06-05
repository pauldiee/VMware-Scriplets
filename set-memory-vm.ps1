$offlinevms = (Get-VMHost "srv-mtw-esxw-41*" | Get-VM | Where-Object {$_.PowerState -eq "PoweredOff"})

foreach ($vm in $offlinevms){
    Set-VM -VM $vm -MemoryGB 7 -Confirm:$false | Out-Null
    Write-Host $vm set to 7GB Memory -ForegroundColor Green
}

$templatevm = ""
$templatevm = (Get-Cluster | Get-VMHost | Get-Template -Name "VD_Template_W7x64_srv*" | Sort-Object Name)
foreach ($vm in $templatevm){
    Set-Template $vm -ToVM | Out-Null
    Write-Host $vm set from Template to VM -ForegroundColor Green
    $next = (Get-VM $vm)
    Set-VM $next -MemoryGB 7 -Confirm:$false | Out-Null
    Write-Host $next set to 7GB Memory -ForegroundColor Green
    Set-VM -VM $next -ToTemplate -Confirm:$false | Out-Null
    Write-Host $next set from VM to Template -ForegroundColor Green
}