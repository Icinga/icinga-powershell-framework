function Write-IcingaPluginOutput()
{
    param (
        $Output
    );

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        if ($null -ne $global:Icinga -And $global:Icinga.Minimal) {
            Clear-Host;
        }
        Write-IcingaConsolePlain $Output;
    } else {
        # New behavior with local thread separated results
        $global:Icinga.CheckResults += $Output;
    }
}
