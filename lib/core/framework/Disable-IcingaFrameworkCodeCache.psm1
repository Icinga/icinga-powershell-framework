<#
.SYNOPSIS
   Disables the feature to cache all functions into a single file,
   allowing quicker loading times of the Icinga PowerShell Framework
.DESCRIPTION
   Disables the feature to cache all functions into a single file,
   allowing quicker loading times of the Icinga PowerShell Framework
.FUNCTIONALITY
   Disables the Icinga for Windows code caching
.EXAMPLE
   PS>Disable-IcingaFrameworkCodeCache;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaFrameworkCodeCache()
{
    Set-IcingaPowerShellConfig -Path 'Framework.CodeCaching' -Value $FALSE;

    # Remove the cache file in case it exists and the feature is disabled
    if (Test-Path -Path (Get-IcingaFrameworkCodeCacheFile)) {
        Remove-ItemSecure -Path (Get-IcingaFrameworkCodeCacheFile) -Force | Out-Null;
    }
}
