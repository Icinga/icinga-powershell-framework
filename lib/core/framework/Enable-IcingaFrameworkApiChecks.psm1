<#
.SYNOPSIS
   Enables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.DESCRIPTION
   Enables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.FUNCTIONALITY
   Enables the Icinga for Windows Api checks forwarded
.EXAMPLE
   PS>Enable-IcingaFrameworkApiChecks;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaFrameworkApiChecks()
{
    Set-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks' -Value $TRUE;

    Write-IcingaConsoleWarning 'Experimental Feature: Please ensure to install the packages "icinga-powershell-restapi" and "icinga-powershell-apichecks", install the Icinga for Windows background service and also register the daemon with "Register-IcingaBackgroundDaemon -Command {0}". Afterwards all services will be executed by the background daemon in case it is running.' -Objects "'Start-IcingaWindowsRESTApi'";
}
