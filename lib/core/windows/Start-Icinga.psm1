function Start-Icinga()
{
    Start-IcingaService -Service 'icinga2';
    Start-IcingaForWindows;
}
