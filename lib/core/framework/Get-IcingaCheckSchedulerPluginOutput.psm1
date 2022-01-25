<#
.SYNOPSIS
   Function to fetch the last executed plugin output from an internal memory
   cache in case the Framework is running as daemon.
.DESCRIPTION
   While running the Framework as daemon, checkresults for plugins are not
   printed into the console but written into an internal memory cache. Once
   a plugin was executed, use this function to fetch the plugin output
.FUNCTIONALITY
   Returns the last checkresult output for executed plugins while the
   Framework is running as daemon
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaCheckSchedulerPluginOutput()
{
    $CheckResult                                  = [string]::Join("`r`n", $Global:Icinga.Private.Scheduler.CheckResults);
    $Global:Icinga.Private.Scheduler.CheckResults = @();

    return $CheckResult;
}
