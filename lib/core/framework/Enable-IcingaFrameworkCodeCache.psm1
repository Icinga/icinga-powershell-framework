<#
.SYNOPSIS
   Enables the feature to cache all functions into a single file,
   allowing quicker loading times of the Icinga PowerShell Framework
.DESCRIPTION
   Enables the feature to cache all functions into a single file,
   allowing quicker loading times of the Icinga PowerShell Framework
.FUNCTIONALITY
   Enables the Icinga for Windows code caching
.EXAMPLE
   PS>Enable-IcingaFrameworkCodeCache;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaFrameworkCodeCache()
{
    Set-IcingaPowerShellConfig -Path 'Framework.CodeCaching' -Value $TRUE;

    Write-IcingaConsoleWarning 'Please run "Write-IcingaFrameworkCodeCache" in addition to ensure your cache is updated. This should be done after each update of the Framework in case the feature was disabled during the update run.';
}
