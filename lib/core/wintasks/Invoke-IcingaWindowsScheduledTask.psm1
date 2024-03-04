function Invoke-IcingaWindowsScheduledTask()
{
    param (
        [ValidateSet('UninstallAgent', 'UpgradeAgent', 'ReadMSIPackage', 'InstallJEA', 'StartWindowsService', 'StopWindowsService', 'RestartWindowsService', 'GetWindowsService')]
        [string]$JobType    = '',
        [string]$FilePath   = '',
        [string]$TargetPath = '',
        [string]$ObjectName = ''
    );

    if ((Test-AdministrativeShell) -eq $FALSE) {
        Write-IcingaConsoleError 'You require to run this shell in administrative mode for the action "{0}" and object "{1}"' -Objects $JobType, $ObjectName;
        return $null;
    }

    [string]$TaskName = 'Management Task';
    [string]$TaskPath = '\Icinga\Icinga for Windows\';
    $TaskData         = $null;
    $TmpFile          = New-IcingaTemporaryFile;

    if (Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$FALSE -ErrorAction SilentlyContinue | Out-Null;
    }

    switch ($JobType) {
        'StartWindowsService' {
            $TaskData = Invoke-IcingaWindowsServiceHandlerTask -ScriptPath 'jobs\StartWindowsService.ps1' -ServiceName $ObjectName -TmpFile $TmpFile.FullName -TaskName $TaskName -TaskPath $TaskPath;
        };
        'StopWindowsService' {
            $TaskData = Invoke-IcingaWindowsServiceHandlerTask -ScriptPath 'jobs\StopWindowsService.ps1' -ServiceName $ObjectName -TmpFile $TmpFile.FullName -TaskName $TaskName -TaskPath $TaskPath;
        };
        'RestartWindowsService' {
            $TaskData = Invoke-IcingaWindowsServiceHandlerTask -ScriptPath 'jobs\RestartWindowsService.ps1' -ServiceName $ObjectName -TmpFile $TmpFile.FullName -TaskName $TaskName -TaskPath $TaskPath;
        };
        'GetWindowsService' {
            $TaskData = Invoke-IcingaWindowsServiceHandlerTask -ScriptPath 'jobs\GetWindowsService.ps1' -ServiceName $ObjectName -TmpFile $TmpFile.FullName -TaskName $TaskName -TaskPath $TaskPath;
        };
        'UninstallAgent' {
            $WinAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ([string]::Format('-WindowStyle Hidden -Command &{{ Use-Icinga -Minimal; Write-IcingaFileSecure -File {0}{1}{0} -Value (Start-IcingaProcess -Executable {0}MsiExec.exe{0} -Arguments {0}"{2}" /q{0} -FlushNewLines | ConvertTo-Json -Depth 100); }}', "'", $TmpFile.FullName, $FilePath, $TargetPath))
            Register-ScheduledTask -TaskName $TaskName -Action $WinAction -RunLevel Highest -TaskPath $TaskPath | Out-Null;

            Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath;

            Wait-IcingaWindowsScheduledTask;
            # Wait some time before continuing to ensure the service is properly removed
            Start-Sleep -Seconds 2;

            [string]$TaskOutput = Read-IcingaFileSecure -File $TmpFile.FullName;
            $TaskData = ConvertFrom-Json $TaskOutput;
        };
        'UpgradeAgent' {

        };
        'ReadMSIPackage' {
            if (Test-Path $FilePath) {

                $WinAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ([string]::Format('-WindowStyle Hidden -Command &{{ Use-Icinga -Minimal; Write-IcingaFileSecure -File {0}{1}{0} -Value (Read-IcingaMSIMetadata -File {0}{2}{0} | ConvertTo-Json -Depth 100); }}', "'", $TmpFile.FullName, $FilePath))
                Register-ScheduledTask -TaskName $TaskName -Action $WinAction -RunLevel Highest -TaskPath $TaskPath | Out-Null;

                Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath;

                Wait-IcingaWindowsScheduledTask;

                [string]$TaskOutput = Read-IcingaFileSecure -File $TmpFile.FullName;
                $TaskData = ConvertFrom-Json $TaskOutput;
            } else {
                Write-IcingaConsoleError 'Unable to execute Job Type {0} because the specified file "{1}" does not exist' -Objects $JobType, $FilePath;
            }
        };
        'InstallJEA' {
            $WinAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ([string]::Format('-Command &{{ Use-Icinga -Minimal; Install-IcingaJEAProfile; Restart-IcingaWindowsService; }}', "'", $TmpFile.FullName, $FilePath))
            Register-ScheduledTask -TaskName $TaskName -Action $WinAction -RunLevel Highest -TaskPath $TaskPath | Out-Null;
            Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath;

            Wait-IcingaWindowsScheduledTask;

            # No output data required for this task
        };
        Default {
            Write-IcingaConsoleError 'Unable to execute Job Type {0}. Undefined operation' -Objects $JobType;
        };
    };

    if (Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$FALSE -ErrorAction SilentlyContinue | Out-Null;
    }

    if (Test-Path $TmpFile) {
        Remove-Item -Path $TmpFile -Force;
    }

    return $TaskData;
}
