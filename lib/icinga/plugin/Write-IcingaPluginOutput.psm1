function Write-IcingaPluginOutput()
{
    param (
        $Output
    );

    if ($Global:Icinga.Protected.RunAsDaemon -eq $FALSE -And $Global:Icinga.Protected.JEAContext -eq $FALSE) {
        if ($Global:Icinga.Protected.Minimal) {
            Clear-Host;
        }
        Write-IcingaConsolePlain $Output;
    } else {
        # New behavior with local thread separated results
        $global:Icinga.Private.Scheduler.CheckResults += $Output;
    }
}
