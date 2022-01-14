<#
.SYNOPSIS
   Disables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.DESCRIPTION
   Disables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.FUNCTIONALITY
   Disables the Icinga for Windows Api checks forwarded
.EXAMPLE
   PS>Disable-IcingaFrameworkApiChecks;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaFrameworkApiChecks()
{
    Set-IcingaPowerShellConfig -Path 'Framework.ApiChecks' -Value $FALSE;
}
