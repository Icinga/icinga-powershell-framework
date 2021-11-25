<#
.SYNOPSIS
    Creates all environment variables for Icinga for Windows for the
    PowerShell session
.DESCRIPTION
    Creates all environment variables for Icinga for Windows for the
    PowerShell session
.EXAMPLE
    New-IcingaEnvironmentVariable;
#>

function New-IcingaEnvironmentVariable()
{
    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    # Session specific configuration for this shell
    if ($global:Icinga.ContainsKey('Private') -eq $FALSE) {
        $global:Icinga.Add('Private', @{ });
    }

    # Shared configuration for all threads
    if ($global:Icinga.ContainsKey('Public') -eq $FALSE) {
        $global:Icinga.Add('Public', [hashtable]::Synchronized(@{ }));
    }

    if ($global:Icinga.ContainsKey('CheckResults') -eq $FALSE) {
        $global:Icinga.Add('CheckResults', @());
    }
    if ($global:Icinga.ContainsKey('PerfData') -eq $FALSE) {
        $global:Icinga.Add('PerfData', @());
    }
    if ($global:Icinga.ContainsKey('CheckData') -eq $FALSE) {
        $global:Icinga.Add('CheckData', @{ });
    }
}
