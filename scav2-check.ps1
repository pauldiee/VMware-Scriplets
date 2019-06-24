<#
=============================================================================================================
Script:    		    scav2-check.ps1
Date:      		    June, 2019
Create By:          Paul van Dieën
Last Edited by:	    Paul van Dieën
Last Edited Date:   23-06-2019
Requirements:		Powershell Framework 5.1
                    PowerCLI 11.3
=============================================================================================================
.DESCRIPTION
Script used to check SCAv2 settings and enable or disable them.
#>

#checking Virten modules
Write-Host "Checking Virten Modules" -BackgroundColor Yellow -ForegroundColor Black
if (!(get-module -Name Virten.net.VimAutomation -ListAvailable)){    
    Write-Host -ForegroundColor Cyan "Virten Module not Installed, Installing it to Current User"
    Find-Module -Name Virten.net.VimAutomation | Install-Module -Scope CurrentUser -Force | Out-Null
    Write-Host -foregroundcolor Yellow "Installed Virten version: $(Get-Module -Name Virten.* -ListAvailable | Select-Object -ExpandProperty Version)"
}else {
    Write-Host -foregroundcolor Yellow "Using Virten version: $(Get-Module -Name Virten.* -ListAvailable | Select-Object -ExpandProperty Version)"
}

#checking PowerCLI modules
Write-Host "Checking PowerCLI modules" -BackgroundColor Yellow -ForegroundColor Black
if (!(get-module -Name VMware.PowerCLI* -ListAvailable)){
    Write-Host -ForegroundColor Cyan "PowerCLI Module not Installed. Installing it to Current User"
    Find-Module -Name VMware.PowerCLI* | Install-Module -Scope CurrentUser -AllowClobber -Force | Out-Null
    Write-Host -ForegroundColor Yellow "Installed PowerCLI version: $(Get-Module -Name VMware.PowerCLI* -ListAvailable | Select-Object -ExpandProperty Version)"
}else {
    Write-Host -ForegroundColor Yellow "Using PowerCLI version: $(Get-Module -Name VMware.PowerCLI* -ListAvailable | Select-Object -ExpandProperty Version)"
}

#Connect to vCenter
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Please fill in all information for vCenter Connection!"
$vcenter = Read-Host "Enter vCenter name"
$vCenterCredential = Get-Credential

Connect-VIServer $vcenter -Credential $vCenterCredential -Force -ErrorAction Stop | Out-Null
Write-host -ForegroundColor Green "Connected to vCenter server: $($global:DefaultVIServer.Name)"

#Select Cluster
$cluster =  get-cluster | Sort-Object | Select-Object -ExpandProperty Name | Out-GridView -Title "Select Cluster to check" -OutputMode Single

#Check if SCAv2 is enabled
$allhosts = (Get-Cluster $cluster | Get-VMHost | Sort-Object Name)
foreach ($esxhost in $allhosts){
    if ((Get-VMHost $esxhost |Where-Object {$_.ConnectionState -eq "Maintenance" -or "Connected"})){
        if (Get-VMHost $esxhost | Get-VMHostVersion | Where-Object {$_.UpdateRelease -eq "ESXi 6.7 U2"}){
            if (Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM |Where-Object {$_.Value -eq $false}){
                Write-Host SCAv2 is enabled on $esxhost -ForegroundColor Green
                $continue1 = Read-Host "Do you want to disable SCAv2 Mitigation? (y/n)"
                if ($continue1 -eq "y"){
                    Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM | Set-AdvancedSetting -Value $true -Confirm:$false | Out-Null
                    Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigation | Set-AdvancedSetting -Value $false -Confirm:$false | Out-Null
                    Write-Host Disabled SCAv2 on $esxhost! Please REBOOT $esxhost! -ForegroundColor Green
                }else{
                    Write-Host Done nothing to current settings on $esxhost -ForegroundColor Cyan
                }
            } else{
                Write-Host SCAv2 is NOT enabled on $esxhost -ForegroundColor Cyan
                $continue2 = Read-Host "Do you want to enable SCAv2 Mitigation? (y/n)"
                if ($continue2 -eq "y"){
                    Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM | Set-AdvancedSetting -Value $false -Confirm:$false | Out-Null
                    Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigation | Set-AdvancedSetting -Value $true -Confirm:$false | Out-Null
                    Write-Host Enabled SCAv2 on $esxhost! Please REBOOT $esxhost! -ForegroundColor Green
                }else{
                    Write-Host Done nothing to current settings on $esxhost -ForegroundColor Cyan
                }
            }
        }else {
            Write-Host Version of $esxhost is not a minumum of 6.7 Update 2 -ForegroundColor Cyan
        }
    }else {
        Write-Host $esxhost is not Connected no checks performed -ForegroundColor Yellow
    }
}
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}