Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null

#checking Virten modules
write-host "Checking Virten Modules" -NoNewline
if (!(get-module -Name Virten.* -ListAvailable)) {
    write-host -ForegroundColor red " - Virten Module not found!"
} else {
    write-host -ForegroundColor Yellow " - done"
    write-host -foregroundcolor Yellow "Using Virten version: $(Get-Module -Name Virten.* -ListAvailable | Select-Object -ExpandProperty Version)"
}

#checking PowerCLI modules
write-host "Checking PowerCLI modules" -NoNewline
if (!(get-module -Name VMware.* -ListAvailable)) {
    write-host -ForegroundColor red " - PowerCLI module not loaded, loading PowerCLI module"
    if (!(get-module -Name VMware.* -ListAvailable | Import-Module -ErrorAction SilentlyContinue)) {  
        # Error out if loading fails  
        Write-Error "ERROR: Cannot load the VMware Module. Is PowerCLI installed?"  
     }  
} else {
    write-host -ForegroundColor Yellow " - done"
    write-host -foregroundcolor Yellow "Using PowerCLI version: $(Get-Module -Name VMware.PowerCLI -ListAvailable | Select-Object -ExpandProperty Version)"
}

if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

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
        Write-Host HT Mitigation NOT enabled on $esxhost -ForegroundColor Cyan
    }
}
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}