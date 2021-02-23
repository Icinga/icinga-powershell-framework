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
    if ($null -eq $global:Icinga) {
        return;
    }

    Get-IcingaCheckSchedulerPluginOutput | Out-Null;
    Get-IcingaCheckSchedulerPerfData | Out-Null;
    Clear-IcingaCheckSchedulerCheckData;
}
