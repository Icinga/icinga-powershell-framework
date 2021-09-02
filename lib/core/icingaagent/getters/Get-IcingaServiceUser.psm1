function Get-IcingaServiceUser()
{
    $Services = Get-IcingaServices -Service 'icinga2';
    if ($null -eq $Services) {
        $Services = Get-IcingaServices -Service 'icingapowershell';
        if ($null -eq $Services) {
            return $null;
        }
    }

    $Services    = $Services.GetEnumerator() | Select-Object -First 1;
    $ServiceUser = ($Services.Value.configuration.ServiceUser).Replace('.\', '');

    if ($ServiceUser -eq 'LocalSystem') {
        $ServiceUser = 'NT Authority\SYSTEM';
    }

    return $ServiceUser;
}
