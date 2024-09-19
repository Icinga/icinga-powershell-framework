function Stop-Icinga()
{
    Stop-IcingaService -Service 'icinga2';
    Stop-IcingaForWindows;
}
