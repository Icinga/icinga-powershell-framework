function Register-IcingaWindowsScheduledTaskProcessPriority()
{
    param (
        [switch]$Force = $FALSE
    );

    [string]$TaskName = 'Set Process Priority';
    [string]$TaskPath = '\Icinga\Icinga for Windows\';

    $SetProcessPriorityTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue;

    if ($null -ne $SetProcessPriorityTask -And $Force -eq $FALSE) {
        Write-IcingaConsoleWarning -Message 'The {0} task is already present. User -Force to enforce the re-creation' -Objects $TaskName;
        return;
    }

    $ScriptPath    = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath '\jobs\SetProcessPriority.ps1';
    $TaskAction    = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument ([string]::Format("-NoProfile -WindowStyle Hidden -Command &{{ & '{0}' }}", $ScriptPath));
    $TaskPrincipal = New-ScheduledTaskPrincipal -UserId 'S-1-5-18' -RunLevel 'Highest' -LogonType ServiceAccount;
    $TaskSettings  = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -StartWhenAvailable;

    Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Force -Principal $TaskPrincipal -Action $TaskAction -Settings $TaskSettings | Out-Null;

    Write-IcingaConsoleNotice -Message 'The task "{0}" has been successfully registered at location "{1}".' -Objects $TaskName, $TaskPath;
}
