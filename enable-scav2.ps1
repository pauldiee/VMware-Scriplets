$ErrorActionPreference = "SilentlyContinue"
Disconnect-VIServer * -Force -Confirm:$false | Out-Null
$ErrorActionPreference = "Continue"
$vcenter = Read-Host "Enter vCenter FQDN here"
Connect-VIServer $vcenter -Force | Out-Null

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
Disconnect-VIServer * -Force -Confirm:$false