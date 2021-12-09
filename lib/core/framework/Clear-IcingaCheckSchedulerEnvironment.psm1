<#
.SYNOPSIS
   Clears the entire check scheduler cache environment and frees memory as
   well as cleaning the stack
.DESCRIPTION
   Clears the entire check scheduler cache environment and frees memory as
   well as cleaning the stack
.FUNCTIONALITY
   Clears the entire check scheduler cache environment and frees memory as
   well as cleaning the stack
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Clear-IcingaCheckSchedulerEnvironment()
{
    param (
        [switch]$ClearCheckData = $FALSE
    );

    Get-IcingaCheckSchedulerPluginOutput | Out-Null;
    Get-IcingaCheckSchedulerPerfData | Out-Null;

    if ($ClearCheckData) {
        Clear-IcingaCheckSchedulerCheckData;
    }

    $Global:Icinga.Private.Scheduler.PluginException = $null;
    $Global:Icinga.Private.Scheduler.CheckResults    = $null;
    $Global:Icinga.Private.Scheduler.ExitCode        = $null;
}
