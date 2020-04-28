<#
.SYNOPSIS
   Function to fetch the last executed plugin peformance data
   from an internal memory cache in case the Framework is running as daemon.
.DESCRIPTION
   While running the Framework as daemon, checkresults for plugins are not
   printed into the console but written into an internal memory cache. Once
   a plugin was executed, use this function to fetch the plugin performance data
.FUNCTIONALITY
   Returns the last performance data output for executed plugins while the
   Framework is running as daemon
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaCheckSchedulerPerfData()
{
    if ($null -eq $IcingaDaemonData) {
        return $null;
    }

    if ($IcingaDaemonData.ContainsKey('IcingaThreadContent') -eq $FALSE) {
        return $null;
    }

    if ($IcingaDaemonData.IcingaThreadContent.ContainsKey('Scheduler') -eq $FALSE) {
        return $null;
    }

    if ($IcingaDaemonData.IcingaThreadContent.Scheduler.ContainsKey('PluginPerfData') -eq $FALSE) {
        return $null;
    }

    $PerfData = $IcingaDaemonData.IcingaThreadContent.Scheduler.PluginPerfData;
    $IcingaDaemonData.IcingaThreadContent.Scheduler.PluginPerfData = @();

    return $PerfData;
}
