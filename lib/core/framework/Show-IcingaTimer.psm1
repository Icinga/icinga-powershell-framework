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
        [string]$Name    = 'DefaultTimer',
        [switch]$ShowAll = $FALSE
    );

    $TimerObject = Get-IcingaTimer -Name $Name;

    if (-Not $ShowAll) {
         if ($null -eq $TimerObject) {
             Write-IcingaConsoleNotice 'A timer with the name "{0}" does not exist' -Objects $Name;
            return;
        }

        $TimerOutput = New-Object -TypeName PSObject;
        $TimerOutput | Add-Member -MemberType NoteProperty -Name 'Timer Name' -Value $Name;
        $TimerOutput | Add-Member -MemberType NoteProperty -Name 'Elapsed Seconds' -Value $TimerObject.Elapsed.TotalSeconds;

        $TimerOutput | Format-Table -AutoSize;
    } else {
        $TimerObjects = Get-IcingaHashtableItem -Key 'IcingaTimers' -Hashtable $global:IcingaDaemonData;

        [array]$MultiOutput = @();

        foreach ($TimerName in $TimerObjects.Keys) {
           $TimerObject = $TimerObjects[$TimerName].Timer;

           $TimerOutput = New-Object -TypeName PSObject;
           $TimerOutput | Add-Member -MemberType NoteProperty -Name 'Timer Name' -Value $TimerName;
           $TimerOutput | Add-Member -MemberType NoteProperty -Name 'Elapsed Seconds' -Value $TimerObject.Elapsed.TotalSeconds;
           $MultiOutput += $TimerOutput;
        }

        $MultiOutput | Format-Table -AutoSize;
    }
}
