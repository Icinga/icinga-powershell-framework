function Get-IcingaServiceUser()
{
    if ([string]::IsNullOrEmpty($Global:Icinga.Protected.IcingaServiceUser) -eq $FALSE) {
        return $Global:Icinga.Protected.IcingaServiceUser;
    }

    $Services = Get-IcingaWindowsServiceStatus -Service 'icinga2';
    if ($Services.Present -eq $FALSE) {
        $Services = Get-IcingaWindowsServiceStatus -Service 'icingapowershell';
        if ($Services.Present -eq $FALSE) {
            return 'NT Authority\NetworkService';
        }
    }

    $ServiceUser = (Get-IcingaWindowsInformation Win32_Service |
        ForEach-Object {
            if ($_.Name -Like $Services.Name) {
                return $_;
            }
    } | Select-Object StartName).StartName;

    $ServiceUser = $ServiceUser.Replace('.\', '');

    if ($ServiceUser -eq 'LocalSystem') {
        $ServiceUser = 'NT Authority\SYSTEM';
    }

    $Global:Icinga.Protected.IcingaServiceUser = $ServiceUser;

    return $ServiceUser;
}
