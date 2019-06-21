#checking Virten modules
Write-Host "Checking Virten Modules" -BackgroundColor Yellow -ForegroundColor Black
if (!(get-module -Name Virten.net.VimAutomation -ListAvailable)){    
    if((Test-Connection -ComputerName 'www.microsoft.com' -Quiet)){
        Write-Host -ForegroundColor Cyan "Virten Module not Installed, Installing it to Current User"
        Find-Module -Name Virten.net.VimAutomation | Install-Module -Scope CurrentUser -Force | Out-Null
        Write-Host -foregroundcolor Yellow "Installed Virten version: $(Get-Module -Name Virten.* -ListAvailable | Select-Object -ExpandProperty Version)"
    } else {
        Write-Error "ERROR: Cannot connect to Powershell Gallery" -ErrorAction Stop
    }
}else {
    Write-Host -foregroundcolor Yellow "Using Virten version: $(Get-Module -Name Virten.* -ListAvailable | Select-Object -ExpandProperty Version)"
}

#checking PowerCLI modules
Write-Host "Checking PowerCLI modules" -BackgroundColor Yellow -ForegroundColor Black
if (!(get-module -Name VMware.PowerCLI* -ListAvailable)){
    if((Test-Connection -ComputerName 'www.microsoft.com' -Quiet)){
        Write-Host -ForegroundColor Cyan "PowerCLI Module not Installed. Installing it to Current User"
        Find-Module -Name VMware.PowerCLI* | Install-Module -Scope CurrentUser -AllowClobber -Force | Out-Null
        Write-Host -ForegroundColor Yellow "Installed PowerCLI version: $(Get-Module -Name VMware.PowerCLI* -ListAvailable | Select-Object -ExpandProperty Version)"
    } else {
        Write-Error "ERROR: Cannot connect to Powershell Gallery" -ErrorAction Stop
    }  
}else {
    Write-Host -ForegroundColor Yellow "Using PowerCLI version: $(Get-Module -Name VMware.PowerCLI* -ListAvailable | Select-Object -ExpandProperty Version)"
}

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
Write-Host -BackgroundColor Yellow -ForegroundColor Black "Please fill in all information for vCenter Connection!"
$vcenter = Read-Host "Enter vCenter name"
$domain = Read-Host "Enter local domain name"
$username = Read-Host "Enter Username"
$password = Read-Host "Enter Password" -AsSecureString

Connect-VIServer $vcenter"."$domain -User $username -Password $password -Force -ErrorAction Stop | Out-Null
Write-host -ForegroundColor Green "Connected to vCenter server: $($global:DefaultVIServer.Name)"

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