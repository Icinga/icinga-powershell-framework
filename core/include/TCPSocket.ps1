$TCPSocket = New-Object -TypeName PSObject;

$TCPSocket | Add-Member -membertype ScriptMethod -name 'CreateTCPSocket' -value {
    param([int]$port);

    [string]$PidFile = $Icinga2.PidManager.PidFileName($port);

    try {
        $TCPSocket = [System.Net.Sockets.TcpListener]$port;
        $TCPSocket.Start();
        $Icinga2.Cache.Sockets.Add($PidFile, $TCPSocket);
        $Icinga2.PidManager.CreatePidFile($port);

        return $TCPSocket;
    }  catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            [string]::Format(
                'Failed to create TCP socket on port "{0}": {1}',
                $port,
                $_.Exception.Message
            )
        );
    }

    return $null;
}

# Properly close sockets, flush PID Files or terminate PowerShell instances as owner of sockets
$TCPSocket | Add-Member -membertype ScriptMethod -name 'CloseTCPSocket' -value {
    param([int]$port);

    [string]$PidFile        = $Icinga2.PidManager.PidFileName($port);
    [bool]$IsExternalSocket = $FALSE;

    # Clear our Socket cache
    # In case the socket does not exist, create a new socket
    if ($Icinga2.Cache.Sockets.ContainsKey($PidFile) -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
                [string]::Format(
                    'The socket of port "{0}" is not part of this PowerShell instance',
                    $port
                )
        );
        $IsExternalSocket = $TRUE;
    } else {
        try {
            $TCPSocket = $Icinga2.Cache.Sockets.$PidFile;
            $TCPSocket.Stop();
            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Info,
                [string]::Format(
                    'Closing TCP socket on port "{0}"',
                    $port
                )
            );
        } catch {
            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Exception,
                [string]::Format(
                    'Failed to close TCP socket on port "{0}": {1}',
                    $port,
                    $_.Exception.Message
                )
            );
        }

        $Icinga2.Cache.Sockets.Remove($PidFile);
    }

    # Delete the PID file from disk in case it exists
    [string]$FullPidPath = $Icinga2.PidManager.FullPidPath($PidFile);
    [int]$ProcessID = $Icinga2.PidManager.ProcessID($FullPidPath);

    $Icinga2.PidManager.RemovePidFile($FullPidPath);

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

$TCPSocket | Add-Member -membertype ScriptMethod -name 'IsSocketOpenAndValid' -value {
    param([int]$port);

    [string]$PidFile = $Icinga2.PidManager.PidFileName($port);

    [string]$FullPidPath = $Icinga2.PidManager.FullPidPath($PidFile);

    if ((Test-Path $FullPidPath) -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            [string]::Format(
                'No PID-File found for TCP socket on port "{0}". Trying to close socket...',
                $port
            )
        );

        # Even when the PID-File does not exist, try to gracefull shutdown the socket
        $this.CloseTCPSocket($port);
        return $FALSE;
    }

    [int]$ProcessID = $Icinga2.PidManager.ProcessID($FullPidPath);

    if ([string]::IsNullOrEmpty($ProcessID) -eq $TRUE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            [string]::Format(
                'No process ID found for socket on port "{0}". Trying to close socket anyway...',
                $port
            )
        );

        # Even when the PID-File does not exist, try to gracefull shutdown the socket
        $this.CloseTCPSocket($port);
        return $FALSE;
    }

    try {
        # Look for the Process over WMI, as we might run as Service User and require
        # to fetch the entire scope of running processes
        if ($Icinga2.PidManager.PidProcess($ProcessID) -ne $null) {
            return $TRUE;
        }

        # Socket does not exist or is not valid. Perform a cleanup and return false
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            [string]::Format(
                'The socket configuration for port "{0}" is not valid. Performing cleanup...',
                $port
            )
        );

        $this.CloseTCPSocket($port);
        return $FALSE;
    } catch [System.Exception] {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            [string]::Format(
                'Exception while trying to lookup the process for socket port "{0}": {1}...',
                $port,
                $_.Exception.Message
            )
        );
    }

    $this.CloseTCPSocket($port);
    return $FALSE;
}

return $TCPSocket;