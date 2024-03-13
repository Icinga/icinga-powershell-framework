function Restart-Icinga()
{
    Restart-IcingaService -Service 'icinga2';
    Restart-IcingaForWindows;
}
