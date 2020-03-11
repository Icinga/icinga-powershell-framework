function Get-IcingaServiceUser()
{
    $Services = Get-IcingaServices -Service 'icinga2';
    if ($null -eq $Services) {
        throw 'Icinga Service not installed';
    }

    $Services    = $Services.GetEnumerator() | Select-Object -First 1;
    $ServiceUser = ($Services.Value.configuration.ServiceUser).Replace('.\', '');

    if ($ServiceUser -eq 'LocalSystem') {
        $ServiceUser = 'NT Authority\SYSTEM';
    }

    return $ServiceUser;
}
