
ASNP Citrix.*
Get-BrokerDesktopGroup | Select-Object Name, DesktopsAvailable

#Sensire
Set-BrokerDesktopGroup -Name "Productie" -ShutdownDesktopsAfterUse $False # MAINTENANCE MODE ON
Set-BrokerDesktopGroup -Name "Acceptatie" -ShutdownDesktopsAfterUse $False # MAINTENANCE MODE ON

Set-BrokerDesktopGroup -Name "Productie" -ShutdownDesktopsAfterUse $True # MAINTENANCE MODE OFF
Set-BrokerDesktopGroup -Name "Acceptatie" -ShutdownDesktopsAfterUse $True # MAINTENANCE MODE OFF

#CAM
Set-BrokerDesktopGroup -Name "Acceptatie" -ShutdownDesktopsAfterUse $False # MAINTENANCE MODE ON
Set-BrokerDesktopGroup -Name "Productie" -ShutdownDesktopsAfterUse $False # MAINTENANCE MODE ON
Set-BrokerDesktopGroup -Name "Windows 10G" -ShutdownDesktopsAfterUse $False # MAINTENANCE MODE ON

Set-BrokerDesktopGroup -Name "Acceptatie" -ShutdownDesktopsAfterUse $True # MAINTENANCE MODE OFF
Set-BrokerDesktopGroup -Name "Productie" -ShutdownDesktopsAfterUse $True # MAINTENANCE MODE OFF
Set-BrokerDesktopGroup -Name "Windows 10G" -ShutdownDesktopsAfterUse $True # MAINTENANCE MODE OFF

#GGZD
Set-BrokerDesktopGroup -Name "Acceptatie" -ShutdownDesktopsAfterUse $False # MAINTENANCE MODE ON
Set-BrokerDesktopGroup -Name "Productie" -ShutdownDesktopsAfterUse $False # MAINTENANCE MODE ON

Set-BrokerDesktopGroup -Name "Acceptatie" -ShutdownDesktopsAfterUse $True # MAINTENANCE MODE OFF
Set-BrokerDesktopGroup -Name "Productie" -ShutdownDesktopsAfterUse $True # MAINTENANCE MODE OFF

#Zuidwester
