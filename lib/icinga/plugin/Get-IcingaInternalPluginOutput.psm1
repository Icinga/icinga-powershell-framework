function Get-IcingaInternalPluginOutput()
{
    if ([string]::IsNullOrEmpty($Global:Icinga.Private.Scheduler.PluginException) -eq $FALSE) {
        return $Global:Icinga.Private.Scheduler.PluginException;
    }

    return $Global:Icinga.Private.Scheduler.CheckResults;
}
