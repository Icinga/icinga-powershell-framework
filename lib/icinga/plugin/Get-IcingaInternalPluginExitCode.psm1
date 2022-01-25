function Get-IcingaInternalPluginExitCode()
{
    return $Global:Icinga.Private.Scheduler.ExitCode;
}
