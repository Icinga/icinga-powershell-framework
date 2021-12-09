function Set-IcingaInternalPluginExitCode()
{
    param (
        $ExitCode = 0
    );

    # Only add the first exit code we should cover during one runtime
    if ($null -eq $Global:Icinga.Private.Scheduler.ExitCode) {
        $Global:Icinga.Private.Scheduler.ExitCode = $ExitCode;
    }
}
