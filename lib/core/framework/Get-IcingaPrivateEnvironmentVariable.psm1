<#
.SYNOPSIS
    Reads a private environment variable from Icinga for Windows
    of the current PowerShell session
.DESCRIPTION
    Reads a private environment variable from Icinga for Windows
    of the current PowerShell session
.PARAMETER Name
    The name of the variable to load the content from
.EXAMPLE
    Get-IcingaPrivateEnvironmentVariable -Name 'AddTypeFunctions';
.NOTES
General notes
#>
function Get-IcingaPrivateEnvironmentVariable()
{
    param (
        [string]$Name
    );

    if ([string]::IsNullOrEmpty($Name)) {
        return $null;
    }

    if ($global:Icinga.Private.ContainsKey($Name) -eq $FALSE) {
        return $null;
    }

    return $global:Icinga.Private[$Name];
}
