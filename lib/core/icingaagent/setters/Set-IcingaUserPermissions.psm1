function Set-IcingaUserPermissions()
{
    param (
        [string]$IcingaUser = (Get-IcingaServiceUser),
        [switch]$Remove     = $FALSE
    );

    Set-IcingaAcl "$Env:ProgramData\icinga2\etc" -IcingaUser $IcingaUser -Remove:$Remove;
    Set-IcingaAcl "$Env:ProgramData\icinga2\var" -IcingaUser $IcingaUser -Remove:$Remove;
    Set-IcingaAcl (Get-IcingaCacheDir) -IcingaUser $IcingaUser -Remove:$Remove;
    Set-IcingaAcl -Directory (Get-IcingaPowerShellConfigDir) -IcingaUser $IcingaUser -Remove:$Remove;
}
