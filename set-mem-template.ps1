Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

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
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}