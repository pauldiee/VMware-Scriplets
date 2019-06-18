$ErrorActionPreference = "SilentlyContinue"
Disconnect-VIServer * -Force -Confirm:$false | Out-Null
$ErrorActionPreference = "Continue"
$vcenter = Read-Host "Enter vCenter FQDN here"
Connect-VIServer $vcenter -Force | Out-Null

#Check if SCAv2 is enabled
$allhosts = (Get-Cluster | Get-VMHost)
foreach ($esxhost in $allhosts){
    if (Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigation |Where-Object {$_.Value -eq $true}){
        Write-Host HT Mitigation enabled on $esxhost -ForegroundColor Green
        if (Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM |Where-Object {$_.Value -eq $false}){
            Write-Host SCAv2 is enabled on $esxhost -ForegroundColor Green
        } else{
            Write-Host SCAv2 is NOT enabled on $esxhost -ForegroundColor Cyan
        }
    } else{
        Write-Host HT Mitigation NOT enabled -ForegroundColor Cyan
    }
}
Disconnect-VIServer * -Force -Confirm:$false | Out-Null