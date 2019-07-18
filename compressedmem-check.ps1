$WorkingDir = split-path -parent $PSCommandPath
Set-Location -Path $WorkingDir

$vCenter = Read-Host -prompt 'Enter FQDN / IP address of vCenter'
Write-Host 'vCenter:' $vCenter ''

# Connect to vCenter with $vCenter variable value
Connect-VIServer -Server $vCenter -Credential (Get-Credential) -Force -ErrorAction Stop

#Create report vm's with compressed mem
$report = @()
foreach($vm in Get-View -ViewType Virtualmachine){
 
    $vms = "" | Select-Object VMName,VMHost,Compressed,Ballooned,Swapped
 
    $vms.VMName = $vm.Name
    $vms.VMHost = Get-View -Id $vm.Runtime.Host -property Name | select -ExpandProperty Name
    $vms.Compressed = $vm.Summary.QuickStats.CompressedMemory
    $vms.Ballooned = $vm.Summary.QuickStats.BalloonedMemory
    $vms.Swapped = $vm.Summary.QuickStats.SwappedMemory
    $Report += $vms
}

$output = $Report | Sort-Object -Property VMName | Where-Object {$_.Compressed -ne "0"}

#Report aanmaken en wegschrijven voor logging
$Header = "VM Compressed Memory Report"
$Report = $output | Select VMName,Compressed | ConvertTo-Html -Head $Header -Property VMName,Compressed -PreContent "<p><h2>VM Compressed Memory Report - $($vcenter)</h2></p><br>"
$reportname = "$($vcenter)-compressedmemvm.html"
$Report | Out-File ".\$($reportname)"

# Close connection to active vCenter
Disconnect-VIServer $vCenter -Confirm:$false
Write-Host 'Connection closed to' $vCenter