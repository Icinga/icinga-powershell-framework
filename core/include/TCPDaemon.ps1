$TCPDaemon = New-Object -TypeName PSObject;

$TCPDaemon | Add-Member -membertype ScriptMethod -name 'Start' -value {

    [int]$Port = $Icinga2.Config.'tcp.socket.port';

    if (-Not $Icinga2.Cache.Certificates.Server) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            [string]::Format(
                'Unable to start TCP socket daemon for port {0}. No valid SSL certificate was loaded.',
                $Port
            )
        );
        return;
    }

    if ($Icinga2.TCPSocket.IsSocketOpenAndValid($Port) -eq $TRUE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            [string]::Format(
                'A PowerShell instance for socket on port "{0}" is already running with PID "{1}"',
                $Port,
                $Icinga2.PidManager.GetPIDByBind($port)
            )
        );
        return;
    }
    $TCPSocket = $Icinga2.TCPSocket.CreateTCPSocket($Port);

    if ($TCPSocket -eq $null) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            [string]::Format(
                'Failed to start TCP socket on port "{0}"',
                $Port
            )
        )
        return;
    }

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Info,
        [string]::Format(
            'Starting new API listener on port "{0}"',
            $Port
        )
    );

    while($true) {
        [System.Net.Sockets.TcpClient]$client = $TCPSocket.AcceptTcpClient();

        $ServerProtocol = Get-Icinga-Lib -Include 'ServerProtocol';
        if ($ServerProtocol.Create($Client) -eq $FALSE) {
            continue;
        }
        $ServerProtocol.ParseRequest();
    }

    $Icinga2.TCPSocket.CloseTCPSocket($Port);
}

$TCPDaemon | Add-Member -membertype ScriptMethod -name 'Stop' -value {
    if ($Icinga2.Utils.AdminShell.IsAdminShell() -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            'Please run this shell as Administrator in order to stop daemon processes'
        );
        return;
    }
    [int]$Port = $Icinga2.Config.'tcp.socket.port';
    $Icinga2.TCPSocket.CloseTCPSocket($Port);

}

return $TCPDaemon;