<#
.SYNOPSIS
   Enables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.DESCRIPTION
   Enables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.FUNCTIONALITY
   Enables the Icinga for Windows Api checks forwarder
.EXAMPLE
   PS>Enable-IcingaFrameworkApiChecks;
.LINK
   https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/30-API-Check-Forwarder/
#>

function Enable-IcingaFrameworkApiChecks()
{
    Set-IcingaPowerShellConfig -Path 'Framework.ApiChecks' -Value $TRUE;
}
