<#
.SYNOPSIS
   Fetches the configuration of the configured Proxy server for the Framework, in
   case it is set
.DESCRIPTION
   etches the configuration of the configured Proxy server for the Framework, in
   case it is set
.FUNCTIONALITY
   etches the configuration of the configured Proxy server for the Framework, in
   case it is set
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaFrameworkProxyServer()
{
    return (Get-IcingaPowerShellConfig -Path 'Framework.Proxy.Server');
}
