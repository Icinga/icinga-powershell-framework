<#
.SYNOPSIS
    Will return certain configuration values for specified users by
    using the username or SID by doing a local lookup with Get-LocalUser,
    in case the Cmdlet is installed
.DESCRIPTION
    Will return certain configuration values for specified users by
    using the username or SID by doing a local lookup with Get-LocalUser,
    in case the Cmdlet is installed.

    Allows to test if a user does exist and if the user is managed by
    Icinga for Windows.

    In case both, -UserName and -SID are used, the -SID argument will always be
    prioritized and therefor only one argument should be used at the same time.
.PARAMETER UserName
    The local username you want to fetch config from
.PARAMETER SID
    The SID of a local user you want to fetch config from. This argument
    will always be prioritized, even when -UserName is set
.EXAMPLE
    PS> Get-IcingaWindowsUserConfig -UserName 'icinga';
.EXAMPLE
    PS> Get-IcingaWindowsUserConfig -SID 'S-1-5-21-1004336348-1177238915-682003330-512';
#>
function Get-IcingaWindowsUserConfig()
{
    param (
        [string]$UserName = '',
        [string]$SID      = ''
    );

    if ([string]::IsNullOrEmpty($SID) -And [string]::IsNullOrEmpty($UserName) -eq $FALSE) {
        $SID = Get-IcingaUserSID -User $UserName;
    }

    $UserConfig = @{
        'SID'               = '';
        'Name'              = '';
        'FullName'          = '';
        'Caption'           = '';
        'Domain'            = (Get-IcingaNetbiosName);
        'Description'       = '';
        'IcingaManagedUser' = $FALSE;
        'UserExist'         = $FALSE;
    };

    if ([string]::IsNullOrEmpty($SID) -And [string]::IsNullOrEmpty($UserName)) {
        return $UserConfig;
    }

    # If we are not running PowerShell 5.0 or later, 'Get-LocalUser' will not be available
    # which should always result in "false" for the managed user
    if ((Test-IcingaFunction 'Get-LocalUser') -eq $FALSE) {
        return $UserConfig;
    }

    $UserMetadata = Get-IcingaWindowsUserMetadata;

    try {
        $UserData = Get-LocalUser -SID $SID -ErrorAction Stop;
    } catch {
        return $UserConfig;
    }

    $UserConfig.SID         = $UserData.SID.Value;
    $UserConfig.Name        = $UserData.Name;
    $UserConfig.FullName    = $UserData.FullName;
    $UserConfig.Caption     = [string]::Format('{0}\{1}', $UserConfig.Domain, $UserData.Name);
    $UserConfig.Description = $UserData.Description;

    if ($UserConfig.FullName -eq $UserMetadata.FullName -And $UserConfig.Description -eq $UserMetadata.Description) {
        $UserConfig.IcingaManagedUser = $TRUE;
    }

    $UserConfig.UserExist = $TRUE;

    return $UserConfig;
}
