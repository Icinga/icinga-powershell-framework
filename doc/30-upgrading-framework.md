# Upgrading Icinga PowerShell Framework

Upgrading Icinga PowerShell Framework is usually quite straightforward. 

Specific version upgrades are described below. Please note that version updates are incremental.

## Upgrading to v1.1.0 (pending)

### Behavior changes

#### Changes on -AcceptConnections

The behaviour on how the `-AcceptConnections` argument of the setup wizard is working has been fixed. Prior to version v1.1.0 the opposite effect took place.

Previous behaviour:

Setting `-AcceptConnections 1` would continue with having to configure endpoint configurations while `-AcceptConnections 0` would open the Windows Firewall for incoming connections

New behavior:

Setting `-AcceptConnections 1` will only configure the Agent to wait for parent node(s) and open the Windows firewall for incoming traffic.
Using `-AcceptConnections 0` is now working properly by letting the Agent establish the connection to the parent node(s)

#### New wizard argument -ConvertEndpointIPConfig

With v1.1.0 a new argument is added to the wizard which will prompt a question if hostnames or FQDN for connection data from the Agent to the parent node(s) shall be converted to IP addresses. If you are unsure of the result, you can manually add `-ConvertEndpointIPConfig 0` to your finished configuration string or scripts or answer the question with `no` to keep the current behavour.

By using `-ConvertEndpointIPConfig 1` or answering the wizard question with `yes`, all endpoint configuration data for your parent node(s) are resolved from hostname/FQDN to IP Addresses if possible
