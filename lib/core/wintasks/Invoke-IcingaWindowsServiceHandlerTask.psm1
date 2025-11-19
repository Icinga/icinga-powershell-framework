function Invoke-IcingaWindowsServiceHandlerTask()
{
    param (
        [string]$ScriptPath  = '',
        [string]$ServiceName = '',
        [string]$TmpFile     = '',
        [string]$TaskName    = '',
        [string]$TaskPath    = ''
    );

    if ([string]::IsNullOrEmpty($ScriptPath)) {
        return $null;
    }

    $ScriptPath = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath $ScriptPath;

    if ((Test-Path $ScriptPath) -eq $FALSE) {
        Write-IcingaConsoleError 'Unable to execute Job. The provided script path "{0}" does not exist' -Objects $ScriptPath;
        return $null;
    }

    $WinAction    = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ([string]::Format("-NoProfile -WindowStyle Hidden -Command &{{ & '{0}' -ServiceName '{1}' -TmpFilePath '{2}' }}", $ScriptPath, $ServiceName, $TmpFile));
    $TaskSettings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -StartWhenAvailable;
    # We need to schedule this task as LocalSystem to ensure we can fetch the information while connected over WinRM/SSH
    # We require high admin privilleges anyway, therefor this shouldn't hurt
    Register-ScheduledTask -User 'System' -TaskName $TaskName -Action $WinAction -TaskPath $TaskPath -Settings $TaskSettings -Force | Out-Null;

    Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath;

    Wait-IcingaWindowsScheduledTask;

    [string]$TaskOutput = Read-IcingaFileSecure -File $TmpFile;
    $TaskData           = ConvertFrom-Json $TaskOutput;

    return $TaskData;
}
