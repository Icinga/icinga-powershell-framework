function Wait-IcingaWindowsScheduledTask()
{
    param (
        [string]$TaskName = 'Management Task',
        [string]$TaskPath = '\Icinga\Icinga for Windows\',
        [int]$Timeout     = 180
    );

    [int]$TimeoutTicks = $Timeout * 1000;

    while ($TimeoutTicks -gt 0) {
        $TaskStatus = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath;
        if ($TaskStatus.State -eq 'Ready') {
            break;
        }
        Start-Sleep -Milliseconds 500;

        $TimeoutTicks -= 500;
    }

    if ($TimeoutTicks -le 0) {
        Stop-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Out-Null;

        Write-IcingaConsoleError 'The scheduled task "{0}" at path "{1}" could not be executed within {2} seconds and run into a timeout' -Objects $TaskName, $TaskPath, $Timeout;
    }
}
