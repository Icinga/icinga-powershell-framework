function Register-IcingaWindowsScheduledTaskRenewCertificate()
{
    param (
        [switch]$Force = $FALSE
    );

    [string]$TaskName = 'Renew Certificate';
    [string]$TaskPath = '\Icinga\Icinga for Windows\';

    $RenewCertificateTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue;

    if ($null -ne $RenewCertificateTask -And $Force -eq $FALSE) {
        Write-IcingaConsoleWarning -Message 'The {0} task is already present. User -Force to enforce the re-creation' -Objects $TaskName;
        return;
    }

    $ScriptPath    = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath '\jobs\RenewCertificate.ps1';
    $TaskTrigger   = New-ScheduledTaskTrigger -Daily -DaysInterval 1 -At '1am';
    $TaskAction    = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument ([string]::Format("-WindowStyle Hidden -Command &{{ & '{0}' }}", $ScriptPath));
    $TaskSettings  = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -StartWhenAvailable;

    # Set our user to execute the renewal script to LocalSystem, ensuring we have enough privilliges to create the certificate file and be able to use WinRM/SSH for service registering
    Register-ScheduledTask -User 'System' -TaskName $TaskName -TaskPath $TaskPath -Force -Action $TaskAction -Trigger $TaskTrigger -Settings $TaskSettings | Out-Null;

    Write-IcingaConsoleNotice -Message 'The task "{0}" has been successfully registered at location "{1}".' -Objects $TaskName, $TaskPath;
}
