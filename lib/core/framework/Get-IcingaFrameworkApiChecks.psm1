<#
.SYNOPSIS
   Fetches the current enable/disable state of the feature
   for executing checks of the internal REST-Api
.DESCRIPTION
   Fetches the current enable/disable state of the feature
   for executing checks of the internal REST-Api
.FUNCTIONALITY
   Get the current API check execution configuration of the
   Icinga PowerShell Framework
.EXAMPLE
   PS>Get-IcingaFrameworkApiChecks;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.OUTPUTS
   System.Boolean
#>

function Get-IcingaFrameworkApiChecks()
{
    $ApiChecks = Get-IcingaPowerShellConfig -Path 'Framework.ApiChecks';

    if ($null -eq $ApiChecks) {
        return $FALSE;
    }

    return $ApiChecks;
}
