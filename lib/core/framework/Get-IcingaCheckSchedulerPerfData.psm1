<#
.SYNOPSIS
    Function to fetch the last executed plugin performance data
    from an internal memory cache in case the Framework is running as daemon.
.DESCRIPTION
    While running the Framework as daemon, check results for plugins are not
    printed into the console but written into an internal memory cache. Once
    a plugin was executed, use this function to fetch the plugin performance data
.FUNCTIONALITY
    Returns the last performance data output for executed plugins while the
    Framework is running as daemon
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaCheckSchedulerPerfData()
{
    [string]$PerfData                                        = $Global:Icinga.Private.Scheduler.PerformanceData;
    [string]$Global:Icinga.Private.Scheduler.PerformanceData = '';

    # Ensure we clear our PerfDataWriter cache and storage to have a clean base state for the next plugin execution
    $Global:Icinga.Private.Scheduler.PerfDataWriter.Cache.Clear() | Out-Null;
    $Global:Icinga.Private.Scheduler.PerfDataWriter.Storage.Clear() | Out-Null;

    return $PerfData;
}
