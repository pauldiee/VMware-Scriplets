<#
=============================================================================================================
Script:    		    DRS-VSANSPBM.ps1
Date:      		    June, 2019
Create By:          Paul van Dieën
Last Edited by:	    Paul van Dieën
Last Edited Date:   05-06-2019
Requirements:		Powershell Framework 5.1
                    PowerCLI 11.2
=============================================================================================================
.DESCRIPTION
Script used to add vm's that are part of a VSAN Storage Policy to a DRS VM Group.
#>
$vcenter = "inf-vcar-0-01.clusum.nl" #Fill in name of vCenter

# Disconnect from any current vCenters
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}

#Connect to vCenter
Connect-VIServer $vcenter -Force -ErrorAction Stop | Out-Null
Write-host -ForegroundColor Green "Connected to vCenter server: $($global:DefaultVIServer.Name)"

#Initialize variables
$DC1VMs = ""
$DC2VMs = ""
$MER1SHOULDRUNVMs = ""
$MER2SHOULDRUNVMs = ""
$addtogroupdc1 = ""
$addtogroupdc2 = ""

#Get VM's with specific Storage Policies
$DC1VMs = (Get-SpbmStoragePolicy -Name "CC|Resources – Geen DC Failover – RAID5 – DC1" | Get-VM | Sort-Object Name)
$DC2VMs = (Get-SpbmStoragePolicy -Name "CC|Resources – Geen DC Failover – RAID5 – DC2" | Get-VM | Sort-Object Name)

#Get VM's currently in DRS VM Groups
$MER1SHOULDRUNVMs = (Get-DrsClusterGroup -Name "Should Run MER 1" | Select-Object -ExpandProperty Member)
$MER2SHOULDRUNVMs = (Get-DrsClusterGroup -Name "Should Run MER 2" | Select-Object -ExpandProperty Member)

#Compare VM's from Storage Policies to currently in DRS VM Group and return difference
$addtogroupdc1 = (Compare-Object -ReferenceObject $MER1SHOULDRUNVMs -DifferenceObject $DC1VMs -PassThru | Where-Object {$_.SideIndicator -eq "=>"} | % {$_.Name})
$addtogroupdc2 = (Compare-Object -ReferenceObject $MER2SHOULDRUNVMs -DifferenceObject $DC2VMs -PassThru | Where-Object {$_.SideIndicator -eq "=>"} | % {$_.Name})

#Add VM's not in DRS VM Group to DRS VM Group
foreach ($vmdc1 in $addtogroupdc1){
    Get-DrsClusterGroup -Name "Should Run MER 1" | Set-DrsClusterGroup -VM $vmdc1 -Add | Out-Null
    Write-Host added $vmdc1 to DRS Group "Should Run MER 1" -ForegroundColor Green
}
#Check if DRS VM Group is ready
if (!$addtogroupdc1){
    Write-Host MER1 DRS VM Group is up to date -ForegroundColor Cyan
}

#Add VM's not in DRS VM Group to DRS VM Group
foreach ($vmdc2 in $addtogroupdc2){
    Get-DrsClusterGroup -Name "Should Run MER 2" | Set-DrsClusterGroup -VM $vmdc2 -Add | Out-Null
    Write-Host added $vmdc2 to DRS Group "Should Run MER 2" -ForegroundColor Green
}

#Check if DRS VM Group is ready
if (!$addtogroupdc2){
    Write-Host MER2 DRS VM Group is up to date -ForegroundColor Cyan
}

if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
#END OF SCRIPT