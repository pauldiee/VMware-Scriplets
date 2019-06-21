# This script needs the virten.net modules to function
# Install-Module -Name Virten.net.VimAutomation

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

#Disable SCAv2
$allhosts = (Get-Cluster | Get-VMHost)
foreach ($esxhost in $allhosts){
    if (Get-VMHost $esxhost |Get-VMHostVersion | Where-Object {$_.UpdateRelease -eq "ESXi 6.7 U2"}){
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
    }else{
        Write-Host Version of $esxhost is not a minumum of 6.7 Update 2 -ForegroundColor Cyan
    }        
}
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}