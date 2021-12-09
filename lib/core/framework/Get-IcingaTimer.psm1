<#
.SYNOPSIS
   Fetches a Stopwatch system object by a given name if initialised with Start-IcingaTimer
.DESCRIPTION
   Fetches a Stopwatch system object by a given name if initialised with Start-IcingaTimer
.FUNCTIONALITY
   Fetches a Stopwatch system object by a given name if initialised with Start-IcingaTimer
.EXAMPLE
   PS>Get-IcingaTimer;
.EXAMPLE
   PS>Get-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.OUTPUTS
   System.Diagnostics.Stopwatch
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    $TimerData = Get-IcingaHashtableItem -Key $Name -Hashtable $Global:Icinga.Private.Timers;

    if ($null -eq $TimerData) {
        return $null;
    }

    return $TimerData.Timer;
}
