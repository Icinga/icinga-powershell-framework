<#
.SYNOPSIS
   Enables the experimental feature to cache all functions into a single file,
   allowing quicker loading times of the Icinga PowerShell Framework
.DESCRIPTION
   Enables the experimental feature to cache all functions into a single file,
   allowing quicker loading times of the Icinga PowerShell Framework
.FUNCTIONALITY
   Experimental: Enables the Icinga for Windows code caching
.EXAMPLE
   PS>Enable-IcingaFrameworkCodeCache;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaFrameworkCodeCache()
{
    Set-IcingaPowerShellConfig -Path 'Framework.Experimental.CodeCaching' -Value $TRUE;

    Write-IcingaConsoleWarning 'This is an experimental feature and might cause some side effects during usage. Please use this function with caution. Please run "Write-IcingaFrameworkCodeCache" in addition to ensure your cache is updated. This should be done after each update of the Framework in case the feature was disabled during the update run.';
}
