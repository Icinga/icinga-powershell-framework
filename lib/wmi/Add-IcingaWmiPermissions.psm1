<#
.SYNOPSIS
    Sets permissions for a specific Wmi namespace for a user. You can grant basic permissions based
    on the arguments available and grant additional ones with the `-Flags` argument.
.DESCRIPTION
    Sets permissions for a specific Wmi namespace for a user. You can grant basic permissions based
    on the arguments available and grant additional ones with the `-Flags` argument.
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
    Blocks the user from having access to this Wmi and or subnamespace tree.
.PARAMETER Flags
    Allows to specify additional flags for permssion granting: PartialWrite, Subscribe, ProviderWrite,ReadSecurity, WriteSecurity, Publish, MethodExecute, FullWrite
.EXAMPLE
    PS>Add-IcingaWmiPermissions -Namespace 'root\cimv2' -User icinga -Enable;
.EXAMPLE
    PS>Add-IcingaWmiPermissions -Namespace 'root\cimv2' -User 'ICINGADOMAIN\icinga' -Enable -RemoteAccess;
.EXAMPLE
    PS>Add-IcingaWmiPermissions -Namespace 'root\cimv2' -User 'ICINGADOMAIN\icinga' -Enable -RemoteAccess -Recurse;
.EXAMPLE
    PS>Add-IcingaWmiPermissions -Namespace 'root\cimv2' -User 'ICINGADOMAIN\icinga' -Enable -RemoteAccess -Flags 'ReadSecurity', 'MethodExecute' -Recurse;
.INPUTS
    System.String
.OUTPUTS
    System.Boolean
#>

function Add-IcingaWmiPermissions()
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

    [int]$PermissionMask = New-IcingaWmiPermissionMask -Enable:$Enable -RemoteAccess:$RemoteAccess -Flags $Flags;

    if ($PermissionMask -eq 0) {
        Write-IcingaConsoleError 'You have to specify permissions to grant for a specific user';
        return $FALSE;
    }

    if (Test-IcingaWmiPermissions -User $User -Namespace $Namespace -Enable:$Enable -RemoteAccess:$RemoteAccess -Recurse:$Recurse -DenyAccess:$DenyAccess -Flags $Flags) {
        Write-IcingaConsoleNotice 'Wmi permissions for user "{0}" are already set.' -Objects $User;
        return $TRUE;
    } else {
        Write-IcingaConsoleNotice 'Removing possible existing configuration for this user before continuing';
        Remove-IcingaWmiPermissions -User $User -Namespace $Namespace | Out-Null;
    }

    $WmiSecurity = Get-IcingaWmiSecurityData -User $User -Namespace $Namespace;

    if ($null -eq $WmiSecurity) {
        return $FALSE;
    }

    $WmiAce            = (New-Object System.Management.ManagementClass("Win32_Ace")).CreateInstance();
    $WmiAce.AccessMask = $PermissionMask;

    if ($Recurse) {
        $WmiAce.AceFlags = $IcingaWBEM.AceFlags.Container_Inherit;
    } else {
        $WmiAce.AceFlags = 0;
    }

    $WmiTrustee           = (New-Object System.Management.ManagementClass("Win32_Trustee")).CreateInstance();
    $WmiTrustee.SidString = Get-IcingaUserSID -User $User;
    $WmiAce.Trustee       = $WmiTrustee

    if ($DenyAccess) {
        $WmiAce.AceType = $IcingaWBEM.AceFlags.Access_Denied;
    } else {
        $WmiAce.AceType = $IcingaWBEM.AceFlags.Access_Allowed;
    }

    $WmiSecurity.WmiAcl.DACL += $WmiAce.PSObject.immediateBaseObject;

    $WmiSecurity.WmiArguments.Name = 'SetSecurityDescriptor';
    $WmiSecurity.WmiArguments.Add('ArgumentList', $WmiSecurity.WmiAcl.PSObject.immediateBaseObject);
    $WmiArguments = $WmiSecurity.WmiArguments;
 
    $WmiSecurityData = Invoke-WmiMethod @WmiArguments;
    if ($WmiSecurityData.ReturnValue -ne 0) {
        Write-IcingaConsoleError 'Failed to set Wmi security descriptor information with error {0}' -Objects $WmiSecurityData.ReturnValue;
        return $FALSE;
    }

    Write-IcingaConsoleNotice 'Wmi permissions for Namespace "{0}" and user "{1}" was set successfully' -Objects $Namespace, $User;

    return $TRUE;
}
