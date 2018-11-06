<#
 # Handle the entire logging process of the module by sending the events
 # to console, the event log and if configured into an own log file.
 # This entire script will return a 'function' handler, dealing with
 # all events.
 # To create log events, simply use the following example:
 #
 # $Icinga2.Log.Write($Icinga2.Enums.LogState.Info, 'This is a info message');
 #>

$IcingaLogger = New-Object -TypeName PSObject;

$IcingaLogger | Add-Member -membertype NoteProperty -name 'noconsole' -value $FALSE;

$IcingaLogger | Add-Member -membertype ScriptMethod -name 'DisableConsole' -value {
    $this.noconsole = $TRUE;
}

$IcingaLogger | Add-Member -membertype ScriptMethod -name 'Write' -value {
    param($Severity, [string]$Message);

    # Only write debug output if enabled
    if ($Severity -eq $Icinga2.Enums.LogState.Debug -And $Icinga2.Config.'logger.debug' -eq $FALSE) {
        return;
    }

    [string]$SeverityToString = $this.GetSeverityAsString($Severity);

    # Format a timestamp to get to know the exact date and time. Example: 2017-13-07 22:09:13.263.263
    $timestamp = Get-Date -Format "yyyy-dd-MM HH:mm:ss.fff";
    [string]$LogMessage = [string]::Format('{0} [{1}]: {2}', $timestamp, $SeverityToString, $Message);

    $this.WriteConsole($Severity, $LogMessage);
    $this.WriteEventLog($Severity, $Message);
    $this.WriteLogFile($Severity, $LogMessage);
}

$IcingaLogger | Add-Member -membertype ScriptMethod -name 'GetConsoleColorFromSeverity' -value {
    param([int]$Severity);

    if ($Icinga2.Enums.LogColor.ContainsKey($Severity) -eq $FALSE) {
        return 'White';
    }

    return $Icinga2.Enums.LogColor[$Severity];
}

$IcingaLogger | Add-Member -membertype ScriptMethod -name 'GetSeverityAsString' -value {
    param([int]$Severity);

    if ($Icinga2.Enums.LogSeverity.ContainsKey($Severity) -eq $FALSE) {
        return 'Undefined';
    }

    return $Icinga2.Enums.LogSeverity[$Severity];
}

$IcingaLogger | Add-Member -membertype ScriptMethod -name 'WriteLogFile' -value {
    param([int]$Severity, [string]$Message);

    [string]$LogDirectory = $Icinga2.Config.'logger.directory';

    if ([string]::IsNullOrEmpty($LogDirectory)) {
        return;
    }

    if (-Not (Test-Path $LogDirectory)) {
        New-Item $LogDirectory -ItemType Directory | Out-Null;

        # Something went wrong while trying to create the directory
        if (-Not (Test-Path $LogDirectory)) {
            $this.WriteConsole($Icinga2.Enums.LogState.Error,
                [string]::Format('Failed to create logfile directory at location "{0}"', $LogDirectory)
            )
            return;
        }
    }

    [string]$LogFile = Join-Path $LogDirectory -ChildPath 'icinga2.log';

    try {
        $LogStream = New-Object System.IO.FileStream(
            $LogFile,
            [System.IO.FileMode]::Append,
            [System.IO.FileAccess]::Write,
            [IO.FileShare]::Read
        );
        $LogWriter = New-Object System.IO.StreamWriter($LogStream);
        $LogWriter.writeLine($Message);
    } catch {
        $this.WriteConsole($Icinga2.Enums.LogState.Error,
                [string]::Format('Failed to write into logfile: "{0}"', $_.Exception.Message)
            )
    } finally {
        $LogWriter.Dispose();
    }
}

$IcingaLogger | Add-Member -membertype ScriptMethod -name 'WriteEventLog' -value {
    param([int]$Severity, [string]$Message);

    try {
        Write-EventLog -LogName "Application" `
                       -Source $Icinga2.Service.servicedisplayname `
                       -EventID (1000 + $Severity) `
                       -EntryType $Icinga2.Enums.EventLogType.$Severity `
                       -Message $Message `
                       -Category $Severity `
                       -ErrorAction Stop;
    } catch {
        $this.WriteLogFile(
            $Icinga2.Enums.LogState.Error,
            $_.Exception.Message
        );
    }
}

$IcingaLogger | Add-Member -membertype ScriptMethod -name 'WriteConsole' -value {
    param([int]$Severity, [string]$Message);

    if ($this.noconsole) {
        return;
    }

    Write-Host $Message -ForegroundColor ($this.GetConsoleColorFromSeverity($Severity))
}

return $IcingaLogger;