<#
=============================================================================================================
Script:    		    onlycheckscav2.ps1
Date:      		    June, 2019
Create By:          Paul van DieÃ«n
Last Edited by:	    Paul van DieÃ«n
Last Edited Date:   23-06-2019
Requirements:		Powershell Framework 5.1
                    PowerCLI 11.3
=============================================================================================================
.DESCRIPTION
Script used to check SCAv2 settings.
#>

$WorkingDir = split-path -parent $PSCommandPath
Set-Location -Path $WorkingDir
$Logfile = $WorkingDir+"\logfile.log"
$htmlfile = $WorkingDir+"\logfile.html"

#cleanup old logfiles
if ((Test-Path -Path $Logfile)){Remove-Item $Logfile -Force -Confirm:$false}
if ((Test-Path -Path $htmlfile)){Remove-Item $htmlfile -Force -Confirm:$false}

#Logging function
Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

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
#$domain = Read-Host "Enter local domain name"
$vCenterCredential = Get-Credential

Connect-VIServer $vcenter -Credential $vCenterCredential -Force -ErrorAction Stop | Out-Null
Write-host -ForegroundColor Green "Connected to vCenter server: $($global:DefaultVIServer.Name)"

#Check if SCAv2 is enabled
$allhosts = (Get-Cluster | Get-VMHost | sort-object Name)
foreach ($esxhost in $allhosts){
    if ((Get-VMHost $esxhost |Where-Object {$_.ConnectionState -eq "Maintenance" -or "Connected"})){
        if (Get-VMHost $esxhost | Get-VMHostVersion | Where-Object {$_.UpdateRelease -eq "ESXi 6.7 U2"}){
            if (Get-VMHost $esxhost | Get-AdvancedSetting VMkernel.Boot.hyperthreadingMitigationIntraVM |Where-Object {$_.Value -eq $false}){
                Write-Host SCAv2 is enabled on $esxhost -ForegroundColor Green
                LogWrite "SCAv2 is enabled on $esxhost"
            } else{
                Write-Host SCAv2 is NOT enabled on $esxhost -ForegroundColor Cyan
                LogWrite "SCAv2 is NOT enabled on $esxhost"
            }
        }else {
            Write-Host Version of $esxhost is not a minumum of 6.7 Update 2 -ForegroundColor Cyan
            LogWrite "Version of $esxhost is not a minumum of 6.7 Update 2"
        }
    }else {
        Write-Host $esxhost is not Connected no checks performed -ForegroundColor Yellow
    }
}

#Convert Logfile to HTML file
$File = Get-Content $LogFile
$FileLine = @()
Foreach ($Line in $File) {
 $MyObject = New-Object -TypeName PSObject
 Add-Member -InputObject $MyObject -Type NoteProperty -Name Check -Value $Line
 $FileLine += $MyObject
}
$FileLine | ConvertTo-Html -Property Check | Out-File $htmlFile

#Send email test
$sendmail = Read-Host "Do you want to send logfile output to Mail? (y/n)"
if ($sendmail -eq "y"){
    $body = get-content $htmlfile | Out-String
    $smtpserver = Read-Host "Fill in smtpserver address"
    $mailto = Read-Host "Type in TO email adresses separated by ,"
    $from = Read-Host "Type in FROM email adress"
    Send-MailMessage -SmtpServer $smtpserver -Body $body -Subject SCAV2Check -To $mailto -From $from -BodyAsHtml
    Write-Host Send log email to $mailto -ForegroundColor Green
}else{
    Write-Host Not sending logfile as email -ForegroundColor Cyan
}

#Disconnect from vCenters
if ($global:DefaultVIServers.Count -gt 0) {Disconnect-VIServer * -Confirm:$false}