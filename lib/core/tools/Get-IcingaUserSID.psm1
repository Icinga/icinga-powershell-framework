function Get-IcingaUserSID()
{
    param(
        [string]$User
    );

    [string]$Username = '';
    [string]$Domain   = '';

    if ($User.Contains('\')) {
        $TmpArray = $User.Split('\');
        $Domain   = $TmpArray[0];
        $Username = $TmpArray[1];
    } else {
        $Domain   = Get-IcingaNetbiosName;
        $Username = $User;
    }

    try {
        $NTUser       = New-Object System.Security.Principal.NTAccount($Domain, $Username);
        $SecurityData = $NTUser.Translate([System.Security.Principal.SecurityIdentifier]);
    } catch {
        throw $_.Exception;
    }

    if ($null -eq $SecurityData) {
        throw 'Failed to fetch user information from system';
    }

    return $SecurityData.Value;
}
