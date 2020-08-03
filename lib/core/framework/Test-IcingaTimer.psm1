<#
.SYNOPSIS
   Tests if a specific timer object is already present and started with Start-IcingaTimer
.DESCRIPTION
   Tests if a specific timer object is already present and started with Start-IcingaTimer
.FUNCTIONALITY
   Tests if a specific timer object is already present and started with Start-IcingaTimer
.EXAMPLE
   PS>Test-IcingaTimer;
.EXAMPLE
   PS>Test-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.OUTPUTS
   Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    $TimerData = Get-IcingaHashtableItem -Key $Name -Hashtable $global:IcingaDaemonData.IcingaTimers;

    if ($null -eq $TimerData) {
        return $FALSE;
    }

    return $TimerData.Active;
}
