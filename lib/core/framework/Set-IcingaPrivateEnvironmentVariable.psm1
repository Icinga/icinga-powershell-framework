<#
.SYNOPSIS
    Sets a private variable for the Icinga for Windows environment
    to use within the current PowerShell Session
.DESCRIPTION
    Sets a private variable for the Icinga for Windows environment
    to use within the current PowerShell Session
.PARAMETER Name
    The name of the variable
.PARAMETER Value
    The value the variable will be assigned with
.EXAMPLE
    Set-IcingaPrivateEnvironmentVariable -Name 'AddTypeFunctions' -Value @{ 'IcingaDiskAttributes', $TRUE };
#>

function Set-IcingaPrivateEnvironmentVariable()
{
    param (
        [string]$Name,
        $Value
    );

    if ([string]::IsNullOrEmpty($Name)) {
        return;
    }

    # Setup the environments in case not present already
    New-IcingaEnvironmentVariable;

    if ($global:Icinga.Private.ContainsKey($Name) -eq $FALSE) {
        $global:Icinga.Private.Add($Name, $Value);
        return;
    }

    $global:Icinga.Private[$Name] = $Value;
}
