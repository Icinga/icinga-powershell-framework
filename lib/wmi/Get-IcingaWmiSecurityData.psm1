<#
.SYNOPSIS
    Returns several information about the Wmi namespace and the provided user data to
    work with them while adding/testing/removing Wmi permissions
.DESCRIPTION
    Returns several information about the Wmi namespace and the provided user data to
    work with them while adding/testing/removing Wmi permissions
.PARAMETER User
    The user to set permissions for. Can either be a local or domain user
.PARAMETER Namespace
    The Wmi namespace to grant permissions for. Required namespaces are listed within each plugin documentation
.INPUTS
    System.String
.OUTPUTS
    System.Hashtable
#>

function Get-IcingaWmiSecurityData()
{
    param (
        [string]$User,
        [string]$Namespace
    );

    [hashtable]$WmiArguments = @{
        'Name'      = 'GetSecurityDescriptor';
        'Namespace' = $Namespace;
        'Path'      = "__systemsecurity=@";
    }

    $WmiSecurityData = Invoke-WmiMethod @WmiArguments;

    if ($WmiSecurityData.ReturnValue -ne 0) {
        Write-IcingaConsoleError 'Fetching Wmi security descriptor information failed with error {0}' -Objects $WmiSecurityData.ReturnValue;
        return $null;
    }

    $UserData = Split-IcingaUserDomain -User $User;
    $UserSID  = Get-IcingaUserSID -User $User;
    $WmiAcl   = $WmiSecurityData.Descriptor;

    $WmiAccount = Get-IcingaWindowsInformation -ClassName Win32_Account -Filter ([string]::Format("Domain='{0}' and Name='{1}'", $UserData.Domain, $UserData.User));

    if ($null -eq $WmiAccount) {
        Write-IcingaConsoleError 'The specified user could not be found on the system: "{0}\{1}"' -Objects $UserData.Domain, $UserData.User;
        return $null;
    }

    if ([string]::IsNullOrEmpty($UserSID)) {
        Write-IcingaConsoleError 'Unable to load the SID for user "{0}"' -Objects $User;
        return $null;
    }

    return @{
        'WmiArguments' = $WmiArguments;
        'UserData'     = $UserData;
        'UserSID'      = $UserSID;
        'WmiAcl'       = $WmiAcl;
    }
}
