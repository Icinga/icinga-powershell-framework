function Get-IcingaInternalPluginExitCode()
{
    return $Global:Icinga.PluginExecution.LastExitCode;
}
