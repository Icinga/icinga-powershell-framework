<#
.SYNOPSIS
    Tests the current set permissions for a user on a specific namespace and returns true if the
    current configuration is matching the intended configuration and returns false if either no
    permissions are set yet or the intended configuration is not matching the current configuration
.DESCRIPTION
    Tests the current set permissions for a user on a specific namespace and returns true if the
    current configuration is matching the intended configuration and returns false if either no
    permissions are set yet or the intended configuration is not matching the current configuration
.PARAMETER User
    The user to set permissions for. Can either be a local or domain user
.PARAMETER Namespace
    The Wmi namespace to grant permissions for. Required namespaces are listed within each plugin documentation
.PARAMETER Enable
    Enables the account and grants the user read permissions. This is a default access right for all users and corresponds to the Enable Account permission on the Security tab of the WMI Control. For more information, see Setting Namespace Security with the WMI Control.
.PARAMETER RemoteAccess
    Allows a user account to remotely perform any operations allowed by the permissions described above. Only members of the Administrators group have this right. WBEM_REMOTE_ACCESS corresponds to the Remote Enable permission on the Security tab of the WMI Control.
.PARAMETER Recurse
    Applies a container inherit flag and grants permission not only on the specific Wmi tree but also objects within this namespace (recommended)
.PARAMETER DenyAccess
    Blocks the user from having access to this Wmi and or sub namespace tree.
.PARAMETER Flags
    Allows to specify additional flags for permission granting: PartialWrite, Subscribe, ProviderWrite,ReadSecurity, WriteSecurity, Publish, MethodExecute, FullWrite
.INPUTS
    System.String
.OUTPUTS
    System.Boolean
#>

function Test-IcingaWmiPermissions()
{
    param (
        [string]$User,
        [string]$Namespace,
        [switch]$Enable,
        [switch]$RemoteAccess,
        [switch]$Recurse,
        [switch]$DenyAccess,
        [array]$Flags
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError 'Please enter a valid username';
        return $FALSE;
    }

    if ([string]::IsNullOrEmpty($Namespace)) {
        Write-IcingaConsoleError 'You have to specify a Wmi namespace to grant permissions for';
        return $FALSE;
    }

    [int]$PermissionMask = [int]$PermissionMask = New-IcingaWmiPermissionMask -Enable:$Enable -RemoteAccess:$RemoteAccess -Flags $Flags;

    if ($PermissionMask -eq 0) {
        Write-IcingaConsoleError 'You have to specify permissions to grant for a specific user';
        return $FALSE;
    }

    $WmiSecurity = Get-IcingaWmiSecurityData -User $User -Namespace $Namespace;

    if ($null -eq $WmiSecurity) {
        return $FALSE;
    }

    [System.Management.ManagementBaseObject]$UserACL = $null;

    foreach ($entry in $WmiSecurity.WmiAcl.DACL) {
        if ($entry.Trustee.SidString -eq $WmiSecurity.UserSID) {
            $UserACL = $entry.PSObject.immediateBaseObject;
            break;
        }
    }

    # No permissions granted for this user
    if ($null -eq $UserACL) {
        return $FALSE;
    }

    [bool]$RecurseMatch = $TRUE;

    if ($Recurse -And $UserACL.AceFlags -ne $IcingaWBEM.AceFlags.Container_Inherit) {
        $RecurseMatch = $FALSE;
    } elseif ($Recurse -eq $FALSE -And $UserACL.AceFlags -ne 0) {
        $RecurseMatch = $FALSE;
    }

    if ($UserACL.AccessMask -ne $PermissionMask -Or $RecurseMatch -eq $FALSE) {
        return $FALSE;
    }

    return $TRUE;
}
