function Unregister-IcingaWindowsScheduledTaskRenewCertificate()
{
    [string]$TaskName = 'Renew Certificate';
    [string]$TaskPath = '\Icinga\Icinga for Windows\';

    $RenewCertificateTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue;

    if ($null -eq $RenewCertificateTask) {
        Write-IcingaConsoleNotice -Message 'The "{0}" task is not present on this system.' -Objects $TaskName;
        return;
    }

    Stop-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Out-Null;
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$FALSE -ErrorAction SilentlyContinue | Out-Null;
    Write-IcingaConsoleNotice -Message 'The "{0}" task was removed from the system.' -Objects $TaskName;
}
