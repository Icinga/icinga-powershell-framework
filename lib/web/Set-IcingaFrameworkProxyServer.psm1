<#
.SYNOPSIS
   Sets the configuration for a proxy server which is used by all Invoke-WebRequests
   to ensure internet connections are working correctly.
.DESCRIPTION
   Sets the configuration for a proxy server which is used by all Invoke-WebRequests
   to ensure internet connections are working correctly.
.FUNCTIONALITY
   Sets the configuration for a proxy server which is used by all Invoke-WebRequests
   to ensure internet connections are working correctly.
.EXAMPLE
   PS>Set-IcingaFrameworkProxyServer -Server 'http://example.com:8080';
.PARAMETER Server
   The server with the port for the Proxy. Example: 'http://example.com:8080'
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Set-IcingaFrameworkProxyServer()
{
    param (
        [string]$Server = ''
    );

    Set-IcingaPowerShellConfig -Path 'Framework.Proxy.Server' -Value $Server;

    Write-IcingaConsoleNotice 'The Proxy server for the PowerShell Framework has been set to "{0}"' -Objects $Server;
}
