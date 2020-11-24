<#
.SYNOPSIS
   Sets the allowed TLS version for communicating with endpoints to TLS 1.2 and 1.1
.DESCRIPTION
   Sets the allowed TLS version for communicating with endpoints to TLS 1.2 and 1.1
.FUNCTIONALITY
   Uses the [Net.ServicePointManager] to set the SecurityProtocol to TLS 1.2 and 1.1
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Set-IcingaTLSVersion()
{
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
}
