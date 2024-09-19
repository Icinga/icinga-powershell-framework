function Start-IcingaWindowsScheduledTaskProcessPriority()
{
    [string]$TaskName = 'Set Process Priority';
    [string]$TaskPath = '\Icinga\Icinga for Windows\';

    $SetProcessPriorityTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue;

    if ($null -eq $SetProcessPriorityTask) {
        Write-IcingaConsoleNotice -Message 'The "{0}" task is not present on this system.' -Objects $TaskName;
        return;
    }

    Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath;
}
