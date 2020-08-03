<#
.SYNOPSIS
   Returns the spent time since Start-IcingaTimer was executed in seconds for
   a specific timer name
.DESCRIPTION
   Returns the spent time since Start-IcingaTimer was executed in seconds for
   a specific timer name
.FUNCTIONALITY
   Returns the spent time since Start-IcingaTimer was executed in seconds for
   a specific timer name
.EXAMPLE
   PS>Show-IcingaTimer;
.EXAMPLE
   PS>Show-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.OUTPUTS
   Single
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Show-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    $TimerObject = Get-IcingaTimer -Name $Name;

    if ($null -eq $TimerObject) {
        Write-IcingaConsoleNotice 'A timer with the name "{0}" does not exist' -Objects $Name;
        return;
    }

    return $TimerObject.Elapsed.TotalSeconds;
}
