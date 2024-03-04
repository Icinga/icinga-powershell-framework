function Start-IcingaWindowsScheduledTaskRenewCertificate()
{
    [string]$TaskName = 'Renew Certificate';
    [string]$TaskPath = '\Icinga\Icinga for Windows\';

    $RenewCertificateTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue;

    if ($null -eq $RenewCertificateTask) {
        Write-IcingaConsoleNotice -Message 'The "{0}" task is not present on this system.' -Objects $TaskName;
        return;
    }

    Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath;
}
