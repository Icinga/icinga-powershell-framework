<#
.SYNOPSIS
   Start a new timer for a given name and stores it within the $globals section
   of the Icinga PowerShell Framework
.DESCRIPTION
   Start a new timer for a given name and stores it within the $globals section
   of the Icinga PowerShell Framework
.FUNCTIONALITY
   Start a new timer for a given name and stores it within the $globals section
   of the Icinga PowerShell Framework
.EXAMPLE
   PS>Start-IcingaTimer;
.EXAMPLE
   PS>Start-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Start-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    if ((Test-IcingaTimer -Name $Name)) {
        Write-IcingaConsoleNotice 'The timer with the name "{0}" is already active' -Objects $Name;
        return;
    }

    # Load the library first
    [System.Reflection.Assembly]::LoadWithPartialName("System.Diagnostics") | Out-Null;
    $TimerObject = New-Object System.Diagnostics.Stopwatch;
    $TimerObject.Start();

    Add-IcingaHashtableItem -Key $Name -Value (
        [hashtable]::Synchronized(
            @{
                'Active' = $TRUE;
                'Timer'  = $TimerObject;
            }
        )
    ) -Hashtable $global:IcingaDaemonData.IcingaTimers -Override | Out-Null;
}
