<#
.SYNOPSIS
   Converts Icinga Network configuration from FQDN to IP
.DESCRIPTION
   This Cmdlet will convert a given Icinga Endpoint configuration based
   on a FQDN to a IPv4 based configuration and returns nothing of the
   FQDN could not be resolved
.FUNCTIONALITY
   Converts Icinga Network configuration from FQDN to IP
.EXAMPLE
   PS>Convert-IcingaEndpointsToIPv4 -NetworkConfig @( '[icinga2.example.com]:5665' );
.PARAMETER NetworkConfig
   An array of Icinga endpoint or single network configuration, like '[icinga2.example.com]:5665'
   which will be converted to IP based configuration
.INPUTS
   System.Array
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Convert-IcingaEndpointsToIPv4()
{
    param (
        [array]$NetworkConfig
    );

    [array]$ResolvedNetwork   = @();
    [array]$UnresolvedNetwork = @();
    [bool]$HasUnresolved      = $FALSE;
    [string]$Domain           = $ENV:UserDNSDomain;

    foreach ($entry in $NetworkConfig) {
        $Network = Get-IPConfigFromString -IPConfig $entry;
        try {
            $ResolvedIP       = [System.Net.Dns]::GetHostAddresses($Network.address);
            $ResolvedNetwork += $entry.Replace($Network.address, $ResolvedIP);
        } catch {
            # Once we failed in first place, try to lookup the "FQDN" with our host domain
            # we are in. Might resolve some issues if our DNS is not knowing the plain
            # hostname and untable to resolve it
            try {
                $ResolvedIP       = [System.Net.Dns]::GetHostAddresses(
                    [string]::Format(
                        '{0}.{1}',
                        $Network.address,
                        $Domain
                    )
                );
                $ResolvedNetwork += $entry.Replace($Network.address, $ResolvedIP);
            } catch {
                $UnresolvedNetwork += $entry;
                $HasUnresolved      = $TRUE;
            }
        }
    }

    return @{
        'Network'    = $ResolvedNetwork;
        'HasErrors'  = $HasUnresolved;
        'Unresolved' = $UnresolvedNetwork;
    };
}
