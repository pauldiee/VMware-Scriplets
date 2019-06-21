
ASNP Citrix.*
# Get broker groups and enable maintenance mode
Get-BrokerDesktopGroup | Set-BrokerDesktopGroup -ShutdownDesktopsAfterUse $False

# Get broker groups and disable maintenance mode
Get-BrokerDesktopGroup | Set-BrokerDesktopGroup -ShutdownDesktopsAfterUse $True
