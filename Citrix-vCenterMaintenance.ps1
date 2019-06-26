
ASNP Citrix.*

#Check Broker groups
Get-BrokerDesktopGroup | select-object Name , ShutdownDesktopsAfterUse, TotalDesktops

# Get broker groups and enable maintenance mode
Get-BrokerDesktopGroup | Set-BrokerDesktopGroup -ShutdownDesktopsAfterUse $False

# Get broker groups and disable maintenance mode
Get-BrokerDesktopGroup | Set-BrokerDesktopGroup -ShutdownDesktopsAfterUse $True
