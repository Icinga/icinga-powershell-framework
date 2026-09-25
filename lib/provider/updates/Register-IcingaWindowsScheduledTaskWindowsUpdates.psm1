<#
.SYNOPSIS
    Registers and starts the Windows Scheduled Task for fetching Windows Updates.
.DESCRIPTION
    Creates a Windows Scheduled Task named 'Fetch Windows Updates' under '\Icinga\Icinga for Windows\'.
    The task is configured to run at system startup under the 'NT AUTHORITY\SYSTEM' account ('S-1-5-18')
    with highest privileges.

    It executes 'jobs\FetchWindowsUpdates.ps1', which continuously fetches pending Windows updates
    every 10 minutes and writes the serialized data atomically into the cache directory.
    Immediately after registration, the task is started.
.FUNCTIONALITY
    Registers and starts the Windows Update background fetch scheduled task.
.PARAMETER Silent
    Suppresses console notice and warning messages.
.PARAMETER Force
    Forces the re-creation of the scheduled task if it already exists.
.EXAMPLE
    PS>Register-IcingaWindowsScheduledTaskWindowsUpdates;
.EXAMPLE
    PS>Register-IcingaWindowsScheduledTaskWindowsUpdates -Force;
.EXAMPLE
    PS>Register-IcingaWindowsScheduledTaskWindowsUpdates -Silent;
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Register-IcingaWindowsScheduledTaskWindowsUpdates()
{
    param (
        [switch]$Silent = $false,
        [switch]$Force  = $FALSE
    );

    [string]$TaskName = 'Fetch Windows Updates';
    [string]$TaskPath = '\Icinga\Icinga for Windows\';

    $FetchUpdatesTask = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue;

    if ($null -ne $FetchUpdatesTask -And $Force -eq $FALSE) {
        if (-not $Silent) {
            Write-IcingaConsoleWarning -Message 'The {0} task is already present. User -Force to enforce the re-creation' -Objects $TaskName;
        }
        return;
    }

    $ScriptPath    = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath '\jobs\FetchWindowsUpdates.ps1';
    $TaskTrigger   = New-ScheduledTaskTrigger -AtStartup;
    $TaskAction    = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument ([string]::Format("-NoProfile -WindowStyle Hidden -Command &{{ & '{0}' }}", $ScriptPath));
    $TaskPrincipal = New-ScheduledTaskPrincipal -UserId 'S-1-5-18' -RunLevel 'Highest' -LogonType ServiceAccount;
    $TaskSettings  = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -StartWhenAvailable;

    Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Force -Principal $TaskPrincipal -Action $TaskAction -Trigger $TaskTrigger -Settings $TaskSettings | Out-Null;
    # Start the task directly after creation
    Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath;

    if (-not $Silent) {
        Write-IcingaConsoleNotice -Message 'The task "{0}" has been successfully registered at location "{1}".' -Objects $TaskName, $TaskPath;
    }
}
