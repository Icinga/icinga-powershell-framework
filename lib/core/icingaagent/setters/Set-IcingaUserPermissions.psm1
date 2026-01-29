<#
.SYNOPSIS
    Apply `Set-IcingaAcl` to the common Icinga for Windows directories.

.DESCRIPTION
    Convenience wrapper that calls `Set-IcingaAcl` for a pre-defined set of Icinga
    directories (configuration, var, cache and PowerShell config directories).
    Use this to consistently apply the same ACL rules to the standard locations.

.PARAMETER IcingaUser
    The account or accounts to grant FullControl. Defaults to the value returned
    by `Get-IcingaServiceUser`.

.OUTPUTS
    None. Operates by calling `Set-IcingaAcl` which emits its own console output.

.NOTES
    - Requires administrative privileges to change ACLs on system folders.
#>
function Set-IcingaUserPermissions()
{
    param (
        [string]$IcingaUser = (Get-IcingaServiceUser)
    );

    Set-IcingaAcl -Directory "$Env:ProgramData\icinga2\etc" -IcingaUser $IcingaUser;
    Set-IcingaAcl -Directory "$Env:ProgramData\icinga2\var" -IcingaUser $IcingaUser;
    Set-IcingaAcl -Directory (Get-IcingaCacheDir) -IcingaUser $IcingaUser;
    Set-IcingaAcl -Directory (Get-IcingaPowerShellConfigDir) -IcingaUser $IcingaUser;
    Set-IcingaAcl -Directory (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'certificate') -IcingaUser $IcingaUser;
}
