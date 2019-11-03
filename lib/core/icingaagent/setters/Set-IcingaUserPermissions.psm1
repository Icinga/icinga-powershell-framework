function Set-IcingaUserPermissions()
{
    Set-IcingaAgentServicePermission | Out-Null;
    Set-IcingaAcl "$Env:ProgramData\icinga2\etc";
    Set-IcingaAcl "$Env:ProgramData\icinga2\var";
    Set-IcingaAcl (Get-IcingaCacheDir);
}
