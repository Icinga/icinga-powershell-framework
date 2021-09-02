<#
.SYNOPSIS
    Removes a user from a specific Wmi namespace
.DESCRIPTION
    Removes a user from a specific Wmi namespace
.PARAMETER User
    The user to set permissions for. Can either be a local or domain user
.PARAMETER Namespace
    The Wmi namespace to grant permissions for. Required namespaces are listed within each plugin documentation
.INPUTS
    System.String
.OUTPUTS
    System.Boolean
#>

function Remove-IcingaWmiPermissions()
{
    param (
        [string]$User,
        [string]$Namespace
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError 'Please enter a valid username';
        return $FALSE;
    }

    if ([string]::IsNullOrEmpty($Namespace)) {
        Write-IcingaConsoleError 'You have to specify a Wmi namespace to grant permissions for';
        return $FALSE;
    }

    $WmiSecurity = Get-IcingaWmiSecurityData -User $User -Namespace $Namespace;

    if ($null -eq $WmiSecurity) {
        return $FALSE;
    }

    [System.Management.ManagementBaseObject[]]$RebasedDACL = @()
    [bool]$UserPresent = $FALSE;

    foreach ($entry in $WmiSecurity.WmiAcl.DACL) {
        if ($entry.Trustee.SidString -ne $WmiSecurity.UserSID) {
            $RebasedDACL += $entry.PSObject.immediateBaseObject;
        } else {
            $UserPresent = $TRUE;
        }
    }

    if ($UserPresent -eq $FALSE) {
        Write-IcingaConsoleNotice 'User "{0}" is not configured for namespace "{1}"' -Objects $User, $Namespace;
        return $TRUE;
    }

    $WmiSecurity.WmiAcl.DACL = $RebasedDACL.PSObject.immediateBaseObject;

    $WmiSecurity.WmiArguments.Name = 'SetSecurityDescriptor';
    $WmiSecurity.WmiArguments.Add('ArgumentList', $WmiSecurity.WmiAcl.PSObject.immediateBaseObject);
    $WmiArguments = $WmiSecurity.WmiArguments

    $WmiSecurityData = Invoke-WmiMethod @WmiArguments;
    if ($WmiSecurityData.ReturnValue -ne 0) {
        Write-IcingaConsoleError 'Failed to set Wmi security descriptor information with error {0}' -Objects $WmiSecurityData.ReturnValue;
        return $FALSE;
    }

    Write-IcingaConsoleNotice 'Removed user "{0}" from Namespace "{1}" successfully' -Objects $User, $Namespace;

    return $TRUE;
}
