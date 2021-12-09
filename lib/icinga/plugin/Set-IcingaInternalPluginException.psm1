function Set-IcingaInternalPluginException()
{
    param (
        [string]$PluginException = ''
    );

    # Only catch the first exception
    if ([string]::IsNullOrEmpty($Global:Icinga.Private.Scheduler.PluginException)) {
        $Global:Icinga.Private.Scheduler.PluginException = $PluginException;
    }
}
