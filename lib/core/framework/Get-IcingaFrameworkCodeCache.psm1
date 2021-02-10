<#
.SYNOPSIS
   Fetches the current enable/disable state of the feature
   for caching the Icinga PowerShell Framework code
.DESCRIPTION
   Fetches the current enable/disable state of the feature
   for caching the Icinga PowerShell Framework code
.FUNCTIONALITY
   Get the current code caching configuration of the
   Icinga PowerShell Framework
.EXAMPLE
   PS>Get-IcingaFrameworkCodeCache;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.OUTPUTS
   System.Boolean
#>

function Get-IcingaFrameworkCodeCache()
{
    $CodeCaching = Get-IcingaPowerShellConfig -Path 'Framework.CodeCaching';

    if ($null -eq $CodeCaching) {
        return $FALSE;
    }

    return $CodeCaching;
}
