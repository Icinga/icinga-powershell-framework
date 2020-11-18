function Get-IcingaUserSID()
{
    param(
        [string]$User
    );

    if ($User -eq 'LocalSystem') {
        $User = 'NT Authority\SYSTEM';
    }

    $UserData = Split-IcingaUserDomain -User $User;

    try {
        $NTUser       = New-Object System.Security.Principal.NTAccount($UserData.Domain, $UserData.User);
        $SecurityData = $NTUser.Translate([System.Security.Principal.SecurityIdentifier]);
    } catch {
        throw $_.Exception;
    }

    if ($null -eq $SecurityData) {
        throw 'Failed to fetch user information from system';
    }

    return $SecurityData.Value;
}
