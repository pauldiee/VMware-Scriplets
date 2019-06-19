$ErrorActionPreference = "SilentlyContinue"
Disconnect-VIServer * -Force -Confirm:$false | Out-Null
$ErrorActionPreference = "Continue"
$vcenter = Read-Host "enter vcenter name"
Connect-VIServer $vcenter".fqdn" -force
$ntphost = Read-Host "enter ntp hostname or ip"

#Configure NTP server
$allhosts = (Get-Cluster | Get-VMHost | Sort-Object Name)
foreach ($esx in $allhosts){
    if ((Get-VMHostNtpServer -VMHost $esx | Where-Object {$_.Name -ne $ntphost})){
        Write-Host NTP Server already set on $esx -ForegroundColor Cyan
    } else {
        Add-VmHostNtpServer -VMHost $esx -NtpServer $ntphost | Out-Null
        #Allow NTP queries outbound through the firewall
        Get-VMHostFirewallException -VMHost $esx | Where-Object {$_.Name -eq "NTP client"} | Set-VMHostFirewallException -Enabled:$true  | Out-Null
        #Start NTP client service and set to automatic
        Get-VmHostService -VMHost $esx | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService  | Out-Null
        Get-VmHostService -VMHost $esx | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "automatic"  | Out-Null
        Write-Host Done setting up NTP on $esx -ForegroundColor Green
    }
}
Disconnect-VIServer -Force -Confirm:$false