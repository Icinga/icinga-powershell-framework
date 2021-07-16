function Set-IcingaInternalPluginExitCode()
{
    param (
        $ExitCode = 0
    );

    if ($null -eq $Global:Icinga) {
        $Global:Icinga = @{ };
    }

    if ($Global:Icinga.ContainsKey('PluginExecution') -eq $FALSE) {
        $Global:Icinga.Add(
            'PluginExecution',
            @{
                'LastExitCode' = $ExitCode;
            }
        )
    } else {
        if ($Global:Icinga.PluginExecution.ContainsKey('LastExitCode') -eq $FALSE) {
            $Global:Icinga.PluginExecution.Add('LastExitCode', $ExitCode);
            return;
        }

        # Only add the first exit code we should cover during one runtime
        if ($null -eq $Global:Icinga.PluginExecution.LastExitCode) {
            $Global:Icinga.PluginExecution.LastExitCode = $ExitCode;
        }
    }
}
