$ErrorActionPreference = "SilentlyContinue"
Disconnect-VIServer * -Force -Confirm:$false | Out-Null
$ErrorActionPreference = "Continue"
$vcenter = Read-Host "Enter vCenter FQDN here"
Connect-VIServer $vcenter -Force | Out-Null

#Disable SCAv2
$allhosts = (Get-Cluster | Get-VMHost)
foreach ($esxhost in $allhosts){
    if (Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigation |Where-Object {$_.Value -eq $true}){
        Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigation | Set-AdvancedSetting -Value $false -Confirm:$false | Out-Null
        Write-Host Disabled HT Mitigation on $esxhost -ForegroundColor Green
        if (Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM |Where-Object {$_.Value -eq $false}){
            Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM | Set-AdvancedSetting -Value $true -Confirm:$false | Out-Null
            Write-Host Disabled SCAv2 on $esxhost -ForegroundColor Green
        } else{            
            Write-Host SCAv2 already disabled on $esxhost -ForegroundColor Cyan
        }
    } else{
        Write-Host HT Mitigation already disabled on $esxhost -ForegroundColor Cyan
    }
}
Disconnect-VIServer * -Force -Confirm:$false