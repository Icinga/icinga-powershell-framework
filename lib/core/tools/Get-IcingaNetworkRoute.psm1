<#
.SYNOPSIS
   Fetch the used interface for our Windows System
.DESCRIPTION
   Newer Windows systems provide a Cmdlet 'Get-NetRoute' for fetching the
   network route configurations. Older systems however do not provide this
   and to ensure some sort of backwards compatibility, we will have a look
   on our route configuration and return the first valid interface found
.FUNCTIONALITY
   This Cmdlet will return first valid IP for our interface
.EXAMPLE
   PS>Get-IcingaNetworkRoute
.OUTPUTS
   System.Array
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Get-IcingaNetworkRoute()
{
    $RouteConfig = (&route print | Where-Object {
        $_.TrimStart() -Like "0.0.0.0*";
    }).Split() | Where-Object {
        return $_;
    };

    $Interface   = @{
        'Destination' = $RouteConfig[0];
        'Netmask'     = $RouteConfig[1];
        'Gateway'     = $RouteConfig[2];
        'Interface'   = $RouteConfig[3];
        'Metric'      = $RouteConfig[4];
    }

    return $Interface;
}
