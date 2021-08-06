function Clear-IcingaWindowsUserPassword()
{
    if ($null -eq $Global:Icinga) {
        return;
    }

    if ($Global:Icinga.ContainsKey('ServiceUserPassword') -eq $FALSE) {
        return;
    }

    $Global:Icinga.ServiceUserPassword = $null;
}
