<#
.SYNOPSIS
    Stops and unregisters the Windows Scheduled Task for fetching Windows Updates.
.DESCRIPTION
    Stops the currently running scheduled task 'Fetch Windows Updates' under
    '\Icinga\Icinga for Windows\' and unregisters it from the Windows Task Scheduler.
.FUNCTIONALITY
    Unregisters the Windows Update background fetch scheduled task.
.EXAMPLE
    PS>Unregister-IcingaWindowsScheduledTaskWindowsUpdates;
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Unregister-IcingaWindowsScheduledTaskWindowsUpdates()
{
    [string]$TaskName = 'Fetch Windows Updates';
    [string]$TaskPath = '\Icinga\Icinga for Windows\';

    $FetchUpdatesTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue;

    if ($null -eq $FetchUpdatesTask) {
        Write-IcingaConsoleNotice -Message 'The "{0}" task is not present on this system.' -Objects $TaskName;
        return;
    }

    Stop-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Out-Null;
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$FALSE -ErrorAction SilentlyContinue | Out-Null;
    Write-IcingaConsoleNotice -Message 'The "{0}" task was removed from the system.' -Objects $TaskName;
}
