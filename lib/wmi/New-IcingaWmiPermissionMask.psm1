<#
.SYNOPSIS
    Generates a permission mask based on the set and provided flags which are used
    for adding/testing Wmi permissions
.DESCRIPTION
    Generates a permission mask based on the set and provided flags which are used
    for adding/testing Wmi permissions
.PARAMETER Enable
    Enables the account and grants the user read permissions. This is a default access right for all users and corresponds to the Enable Account permission on the Security tab of the WMI Control. For more information, see Setting Namespace Security with the WMI Control.
.PARAMETER RemoteAccess
    Allows a user account to remotely perform any operations allowed by the permissions described above. Only members of the Administrators group have this right. WBEM_REMOTE_ACCESS corresponds to the Remote Enable permission on the Security tab of the WMI Control.
.PARAMETER Flags
    Allows to specify additional flags for permssion granting: PartialWrite, Subscribe, ProviderWrite,ReadSecurity, WriteSecurity, Publish, MethodExecute, FullWrite
.INPUTS
    System.String
.OUTPUTS
    System.Int
#>

function New-IcingaWmiPermissionMask()
{
    param (
        [switch]$Enable,
        [switch]$RemoteAccess,
        [array]$Flags
    );

    [int]$PermissionMask = 0;

    if ($Enable) {
        $PermissionMask += $IcingaWBEM.SecurityFlags.WBEM_Enable;
    }
    if ($RemoteAccess) {
        $PermissionMask += $IcingaWBEM.SecurityFlags.WBEM_Remote_Access;
    }

    foreach ($flag in $Flags) {
        if ($flag -like 'Enable' -And $Enable) {
            continue;
        }
        if ($flag -like 'RemoteAccess' -And $RemoteAccess) {
            continue;
        }

        if ($IcingaWBEM.SecurityNames.ContainsKey($flag) -eq $FALSE) {
            Write-IcingaConsoleError 'Invalid Security flag "{0}" . Supported flags: {1}' -Objects $flag, $IcingaWBEM.SecurityNames.Keys;
            return $FALSE;
        }

        $PermissionMask += $IcingaWBEM.SecurityFlags[$IcingaWBEM.SecurityNames[$flag]];
    }

    return $PermissionMask;
}
