function Test-IcingaManagedUser()
{
    param (
        [string]$IcingaUser,
        [string]$SID
    );

    if ([string]::IsNullOrEmpty($SID)) {
        $SID = Get-IcingaUserSID -User $IcingaUser;
    }

    if ([string]::IsNullOrEmpty($SID)) {
        return $FALSE;
    }

    $UserConfig   = Get-IcingaWindowsInformation -Class 'Win32_UserAccount' -Filter ([string]::Format("SID = '{0}'", $SID));
    $UserMetadata = Get-IcingaWindowsUserMetadata;

    if ($null -eq $UserConfig -Or $UserConfig.FullName -ne $UserMetadata.FullName -Or $UserConfig.Description -ne $UserMetadata.Description) {
        return $FALSE;
    }

    return $TRUE;
}
