function Get-IcingaUserSID()
{
    param(
        [string]$User
    );

    if ([string]::IsNullOrEmpty($User)) {
        return $null;
    }

    if ($User -eq 'LocalSystem' -Or $User -eq '.\LocalSystem') {
        $User = 'NT Authority\SYSTEM';
    }

    $UserData = Split-IcingaUserDomain -User $User;

    try {
        $NTUser       = New-Object System.Security.Principal.NTAccount($UserData.Domain, $UserData.User);
        $SecurityData = $NTUser.Translate([System.Security.Principal.SecurityIdentifier]);
    } catch {
        try {
            # Try again but this time with our domain
            $UserData.Domain = (Get-IcingaWindowsInformation -ClassName Win32_ComputerSystem).Domain;
            $NTUser          = New-Object System.Security.Principal.NTAccount($UserData.Domain, $UserData.User);
            $SecurityData    = $NTUser.Translate([System.Security.Principal.SecurityIdentifier]);
        } catch {
            return $null;
        }
    }

    if ($null -eq $SecurityData) {
        return $null;
    }

    return $SecurityData.Value;
}
