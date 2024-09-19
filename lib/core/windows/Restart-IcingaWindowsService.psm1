function Restart-IcingaForWindows()
{
    Stop-IcingaForWindows;
    Start-IcingaForWindows;
}

Set-Alias -Name 'Restart-IcingaWindowsService' -Value 'Restart-IcingaForWindows';
