Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $true -Confirm:$false | Out-Null
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}
$vcenter = Read-Host "enter vcenter name"
$domain = Read-Host "Enter local domain"
$ntphost = Read-Host "enter ntp hostname or ip"
Connect-VIServer $vcenter"."$domain -Force -ErrorAction Stop | Out-Null

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
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}