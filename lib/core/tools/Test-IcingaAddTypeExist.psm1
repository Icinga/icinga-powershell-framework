<#
.SYNOPSIS
    Tests if a Add-Type function is already installed inside the current
    PowerShell session
.DESCRIPTION
    Tests if a Add-Type function is already installed inside the current
    PowerShell session
.PARAMETER Type
    The name of the function being added
.EXAMPLE
    Test-IcingaAddTypeExis -Type 'IcingaDiskAttributes';
#>
function Test-IcingaAddTypeExist()
{
    param (
        [string]$Type = $null
    );

    if ([string]::IsNullOrEmpty($Type)) {
        return $FALSE;
    }

    [hashtable]$LoadedTypes = Get-IcingaPrivateEnvironmentVariable -Name 'AddTypeFunctions';

    if ($null -eq $LoadedTypes) {
        $LoadedTypes = @{ };
    }

    if ($LoadedTypes.ContainsKey($Type)) {
        return $TRUE;
    }

    foreach ($entry in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
        if ($entry.GetTypes() -Match $Type) {
            $LoadedTypes.Add($Type, $TRUE);

            Set-IcingaPrivateEnvironmentVariable -Name 'AddTypeFunctions' -Value $LoadedTypes;

            return $TRUE;
        }
    }

    return $FALSE;
}
