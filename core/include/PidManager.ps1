$PidManager = New-Object -TypeName PSObject;

$PidManager | Add-Member -membertype ScriptMethod -name 'PidExists' -value {
    param([string]$bind);

    [string]$PidFile = $this.PidFileName($bind);

    return (Test-Path ($this.FullPidPath($PidFile)));
}

$PidManager | Add-Member -membertype ScriptMethod -name 'CreatePidFile' -value {
    param([string]$bind);

    [string]$PidFile = $this.PidFileName($bind);

    Add-Content -Path ($this.FullPidPath($PidFile)) -Value $pid;
}

$PidManager | Add-Member -membertype ScriptMethod -name 'PidFileName' -value {
    param([string]$bind);

    return [string]::Format(
        'icingabind{0}.pid',
        $bind
    );
}

$PidManager | Add-Member -membertype ScriptMethod -name 'FullPidPath' -value {
    param([string]$PidFile);

    return (Join-Path $Icinga2.App.RootPath -ChildPath (
        [string]::Format(
            '\agent\state\{0}',
            $PidFile
        )
    ));
}

$PidManager | Add-Member -membertype ScriptMethod -name 'ProcessID' -value {
    param([string]$FullPidFile);

    if ((Test-Path $FullPidFile) -eq $FALSE) {
        return 0;
    }

    return Get-Content -Path $FullPidFile;
}

$PidManager | Add-Member -membertype ScriptMethod -name 'GetPIDByBind' -value {
    param([string]$bind);

    return $this.ProcessID(
        $this.FullPidPath(
            $this.PidFileName(
                $bind
            )
        )
    );
}

$PidManager | Add-Member -membertype ScriptMethod -name 'GetPIDPathByBind' -value {
    param([string]$bind);

    return $this.FullPidPath(
            $this.PidFileName(
                $bind
            )
        );
}

$PidManager | Add-Member -membertype ScriptMethod -name 'RemovePidFile' -value {
    param([string]$FullPidPath, [string]$bind);

    [string]$PidFile = $this.PidFileName($bind);

    if (Test-Path $FullPidPath) {
        Remove-Item $FullPidPath | Out-Null;
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            [string]::Format(
                'Removing PID-File "{0}" for bind "{1}"',
                $PidFile,
                $bind
            )
        );
    } else {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            [string]::Format(
                'PID File "{0}" for bind "{1}" does not exist and could therefor not be removed',
                $PidFile,
                $bind
            )
        );
    }
}

$PidManager | Add-Member -membertype ScriptMethod -name 'PidProcess' -value {
    param([int]$ProcessID);

    if ($ProcessID -eq 0) {
        return $null;
    }

    # Look for the Process over WMI, as we might run as Service User and require
    # to fetch the entire scope of running processes
    $ProcessList = Get-WmiObject Win32_Process | Select-Object ProcessName, ProcessId -ErrorAction Stop;

    foreach ($process in $ProcessList) {
        if ($process.ProcessId -eq $ProcessID) {
            if ($process.ProcessName -eq 'powershell.exe') {
                return $process;
            }
        }
    }

    return $null;
}

$PidManager | Add-Member -membertype ScriptMethod -name 'StopProcessByBind' -value {
    param([string]$bind);

    if ($this.PidExists($bind)) {
        $ProcessId = $this.GetPIDByBind($bind);
        $this.ShutdownProcess($ProcessId);
        $this.RemovePidFile(
            $this.GetPIDPathByBind($bind),
            $bind
        );
    }
}

$PidManager | Add-Member -membertype ScriptMethod -name 'ShutdownProcess' -value {
    param($ProcessID);

    # Close possible PowerShell instances
    if ($Icinga2.PidManager.PidProcess($ProcessID) -ne $null) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            [string]::Format(
                'Trying to terminate process with PID "{0}"',
                $ProcessID
            )
        );
        Stop-Process -Id $ProcessID -Force;
    }
}

return $PidManager;