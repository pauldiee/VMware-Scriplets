<#
=============================================================================================================
Script:    		    set-rootpass.ps1
Date:      		    September, 2019
Create By:          Paul van Dieën
Last Edited by:	    Paul van Dieën
Last Edited Date:   18-09-2019
Requirements:		POSH-SSH Module installed
                    Powershell Framework 5.1
                    PowerCLI 11.4
=============================================================================================================
.DESCRIPTION
This script changes the root password on all hosts in connected vcenter.
#>

#Connect to vCenter
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Please supply FQDN for vCenter Connection!"
$vcenter = Read-Host "Enter vCenter name"

$vc = Connect-VIServer $vcenter -ErrorAction Stop
Write-host -ForegroundColor Green "Connected to vCenter server: $($global:DefaultVIServer.Name)"

#Configure root password
$oldpass = Read-Host "Enter previous password for root"
$newpass = Read-Host "Enter new password for root"

$allhosts = (Get-VMHost | Sort-Object Name).Name
Disconnect-VIServer $vc -Confirm:$false
foreach ($esxhost in $allhosts){
    Connect-VIServer $esxhost -User root -Password $oldpass
    Set-VMHostAccount –UserAccount root –Password $newpass
    if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
}