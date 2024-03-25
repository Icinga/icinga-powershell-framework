function Get-IcingaServiceUser()
{
    $IcingaService = $Global:Icinga.Protected.Environment.'Icinga Service';
    $IfWService    = $Global:Icinga.Protected.Environment.'PowerShell Service';
    # Default User
    $ServiceUser   = 'NT Authority\NetworkService';

    if ($null -eq $IcingaService -Or $null -eq $IfWService) {
        Set-IcingaServiceEnvironment;
    }

    if ($IcingaService.Present) {
        $ServiceUser = $IcingaService.User.Replace('.\', '');
        if ($ServiceUser -eq 'LocalSystem') {
            return 'NT Authority\SYSTEM';
        }
    } elseif ($IfWService.Present) {
        $ServiceUser = $IfWService.User.Replace('.\', '');
        if ($ServiceUser -eq 'LocalSystem') {
            return 'NT Authority\SYSTEM';
        }
    }

    return $ServiceUser;
}
