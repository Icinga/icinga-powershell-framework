function Test-IcingaManagedUser()
{
    param (
        [string]$IcingaUser,
        [string]$SID
    );

    $UserData     = Get-IcingaWindowsInformation -Class 'Win32_UserAccount' | Where-Object { $_.Name -eq $IcingaUser };
    $FullUserData = Get-IcingaWindowsInformation -Class 'Win32_UserAccount' | Where-Object { $_.Caption.ToLower() -eq $IcingaUser.ToLower() };

    if ($null -eq $FullUserData -And $null -eq $UserData -And [string]::IsNullOrEmpty($SID)) {
        return $FALSE;
    }

    if ([string]::IsNullOrEmpty($SID)) {
        $SID = Get-IcingaUserSID -User $IcingaUser;
    }

    $UserConfig   = Get-IcingaWindowsInformation -Class 'Win32_UserAccount' | Where-Object { $_.SID -eq $SID };
    $UserMetadata = Get-IcingaWindowsUserMetadata;

    if ($null -eq $UserConfig -Or $UserConfig.FullName -ne $UserMetadata.FullName -Or $UserConfig.Description -ne $UserMetadata.Description) {
        return $FALSE;
    }

    return $TRUE;
}
