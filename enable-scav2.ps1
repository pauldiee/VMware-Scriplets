Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

#Enable SCAv2
$allhosts = (Get-Cluster | Get-VMHost)
foreach ($esxhost in $allhosts){
    if (Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigation |Where-Object {$_.Value -eq $true}){
        Write-Host HT Mitigation is already enabled on $esxhost -ForegroundColor Cyan
        if (Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM |Where-Object {$_.Value -eq $false}){
            Write-Host SCAv2 is already enabled on $esxhost -ForegroundColor Cyan
        } else{
            Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM | Set-AdvancedSetting -Value $false -Confirm:$false | Out-Null
            Write-Host Enabled SCAv2 on $esxhost -ForegroundColor Green
        }
    } else{
        Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigation | Set-AdvancedSetting -Value $true -Confirm:$false | Out-Null
        Write-Host Enabled HT Mitigation on $esxhost -ForegroundColor Green
    }
}
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}