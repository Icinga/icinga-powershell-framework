function Get-IcingaInternalPluginOutput()
{
    if ([string]::IsNullOrEmpty($Global:Icinga.PluginExecution.PluginException) -eq $FALSE) {
        return $Global:Icinga.PluginExecution.PluginException;
    }

    return $Global:Icinga.CheckResults;
}
