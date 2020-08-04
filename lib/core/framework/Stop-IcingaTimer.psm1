<#
.SYNOPSIS
   Stops a timer object started with Start-IcingaTimer for a specific
   named timer
.DESCRIPTION
   Stops a timer object started with Start-IcingaTimer for a specific
   named timer
.FUNCTIONALITY
   Stops a timer object started with Start-IcingaTimer for a specific
   named timer
.EXAMPLE
   PS>Stop-IcingaTimer;
.EXAMPLE
   PS>Stop-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Stop-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    $TimerObject = Get-IcingaTimer -Name $Name;

    if ($null -eq $TimerObject) {
        return;
    }

    if ($TimerObject.IsRunning) {
        $TimerObject.Stop();
    }
    Add-IcingaHashtableItem -Key $Name -Value (
        [hashtable]::Synchronized(
            @{
                'Active' = $FALSE;
                'Timer'  = $TimerObject;
            }
        )
    ) -Hashtable $global:IcingaDaemonData.IcingaTimers -Override | Out-Null;
}
