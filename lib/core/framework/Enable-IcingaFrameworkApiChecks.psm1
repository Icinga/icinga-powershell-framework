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
    Set-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks' -Value $TRUE;

    Write-IcingaConsoleNotice 'Please ensure to install the components "icinga-powershell-restapi" and "icinga-powershell-apichecks", install the Icinga for Windows Service and also register the daemon with "Register-IcingaBackgroundDaemon -Command {0}". Afterwards all checks will be executed by the background daemon in case it is running. Further details can be found at https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/30-API-Check-Forwarder/' -Objects "'Start-IcingaWindowsRESTApi'";
}
