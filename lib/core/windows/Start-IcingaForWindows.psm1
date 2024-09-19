function Start-IcingaForWindows()
{
    Start-IcingaService -Service 'icingapowershell';
    # Update the process priority after each restart
    Start-IcingaWindowsScheduledTaskProcessPriority;
}
