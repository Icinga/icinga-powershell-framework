function Test-IcingaManagedUser()
{
    param (
        [string]$IcingaUser = '',
        [string]$SID        = ''
    );

    $UserConfig = Get-IcingaWindowsUserConfig -UserName $IcingaUser -SID $SID;

    return $UserConfig.IcingaManagedUser;
}
