function Set-IcingaInternalPluginException()
{
    param (
        [string]$PluginException = ''
    );

    if ($null -eq $Global:Icinga) {
        $Global:Icinga = @{ };
    }

    if ($Global:Icinga.ContainsKey('PluginExecution') -eq $FALSE) {
        $Global:Icinga.Add(
            'PluginExecution',
            @{
                'PluginException' = $PluginException;
            }
        )
    } else {
        if ($Global:Icinga.PluginExecution.ContainsKey('PluginException') -eq $FALSE) {
            $Global:Icinga.PluginExecution.Add('PluginException', $PluginException);
            return;
        }

        # Only catch the first exception
        if ([string]::IsNullOrEmpty($Global:Icinga.PluginExecution.PluginException)) {
            $Global:Icinga.PluginExecution.PluginException = $PluginException;
        }
    }
}
