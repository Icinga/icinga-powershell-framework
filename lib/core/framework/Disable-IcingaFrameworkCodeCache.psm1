<#
.SYNOPSIS
   Disables the experimental feature to cache all functions into a single file,
   allowing quicker loading times of the Icinga PowerShell Framework
.DESCRIPTION
   Disables the experimental feature to cache all functions into a single file,
   allowing quicker loading times of the Icinga PowerShell Framework
.FUNCTIONALITY
   Experimental: Disables the Icinga for Windows code caching
.EXAMPLE
   PS>Disable-IcingaFrameworkCodeCache;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaFrameworkCodeCache()
{
    Set-IcingaPowerShellConfig -Path 'Framework.Experimental.CodeCaching' -Value $FALSE;
}
