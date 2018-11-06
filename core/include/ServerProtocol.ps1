$ServerProtocoll = New-Object -TypeName PSObject;

$ServerProtocoll | Add-Member -membertype NoteProperty -name 'static'   -value $FALSE;
$ServerProtocoll | Add-Member -membertype NoteProperty -name 'Client'   -value $Null;
$ServerProtocoll | Add-Member -membertype NoteProperty -name 'Network'  -value (Get-Icinga-Lib -Include 'NetworkProtocol');
$ServerProtocoll | Add-Member -membertype NoteProperty -name 'Response' -value (Get-Icinga-Lib -Include 'APIResponse');
$ServerProtocoll | Add-Member -membertype NoteProperty -name 'Timer'    -value $Null;
$ServerProtocoll | Add-Member -membertype NoteProperty -name 'Message'  -value $Null;
$ServerProtocoll | Add-Member -membertype NoteProperty -name 'Commands' -value @{};

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'Create' -value {
    param([System.Net.Sockets.TcpClient]$Client);

    $this.Client             = $Client;
    $this.Client.SendTimeout = 2000
    $this.Client.NoDelay     = $TRUE;

    $this.Timer = [System.Diagnostics.Stopwatch]::StartNew();

    $Icinga2.Log.Write(
        $Icinga2.Enums.LogState.Debug,
        'New incoming TCP Client connection'
    );

    $this.Network.Create($Client.GetStream());

    # Just in case we received connections over HTTP, send a short answer message
    # back and close the client request
    if ($this.Network.encrypted -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'Received client connection over HTTP. Rejecting client request.'
        );
        $this.Response.HTTPSRequired();
        $this.Network.WriteMessage(
            $this.Response.Compile()
        );
        $this.Close();
        return $FALSE;
    }

    return $TRUE;
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'ParseRequest' -value {
    # Tell our network protocol to read all messages until
    # EOF is reached
    [SecureString]$message = $this.Network.ReadMessage(-1);

    if ($message -eq $null) {
        return;
    }

    [hashtable]$ApiMessage = $Icinga2.Utils.WebHelper.ParseApiMessage($message);

    if ($ApiMessage -eq $null -Or $ApiMessage.Count -eq 0) {
        $this.SendInternalServerError();
        return;
    }

    if ($Icinga2.Config.'authentication.enabled') {
        [int]$Authenticated = $Icinga2.Utils.AuthHelper.Login(
            $ApiMessage.credentials.user,
            $ApiMessage.credentials.password,
            $ApiMessage.credentials.domain
        );
        if ($Authenticated -eq 0) {
            $this.SendAuthenticationRequired();
            return;
        }
    }

    if ($ApiMessage.headers.ContainsKey('content-length')) {
        [int]$ContentLength = ($ApiMessage.headers['content-length'] - $ApiMessage.content.Length);
        $ApiMessage.content += $Icinga2.Utils.SecureString.ConvertFrom(
            $this.Network.ReadMessage(
                $ContentLength
            )
        );
    }

    $this.Message = $ApiMessage;
    $this.ParseQuery();
    $this.ExecuteQuery();
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'ParseQuery' -value {
    [string]$QueryString = $this.Message.base.query;
    if ($QueryString[0] -eq '?') {
        $QueryString = $QueryString.Substring(
            1,
            $QueryString.Length - 1
        );
    }

    [array]$SplitCommand = $QueryString.Split('&');
    foreach ($command in $SplitCommand) {
        [hashtable]$data = $Icinga2.Utils.WebHelper.ParseUrlCommand($command);
        if ($this.Commands.ContainsKey(($data.GetEnumerator() | Select-Object -First 1).Key) -eq $FALSE) {
            $this.Commands += $data;
        }
    }
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'ExecuteQuery' -value {
    switch($this.IsUrlPathValid(0)) {
        '' {
            switch($this.IsUrlPathValid(1)) {
                'v1' {
                    switch($this.IsUrlPathValid(2)) {
                        'data' {
                            $this.ParseDataV1();
                        };
                        'modules' {
                            $this.ParseModulesV1();
                        };
                        default {
                            $this.SendBadRequest(
                                'Unsupported Cmdlets specified. The following Cmdlets are supported: data, modules'
                            );
                        };
                    }
                };
                default {
                    $this.SendBadRequest(
                        'Unsupported API version specified. The following versions are supported: v1'
                    );
                };
            }
        };
        default {
            $this.SendInternalServerError();
        };
    }
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'GetExecutionTime' -value {
    return $this.Timer.Elapsed.TotalSeconds;
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'ParseDataV1' -value {
    [hashtable]$data =
    @{
        data      = New-Icinga-Monitoring -Include $this.Commands.include -Exclude $this.Commands.exclude;
        execution = $this.GetExecutionTime();
    };

    $this.Response.setContent($data);
    $this.SendOkResponse();
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'ParseModulesV1' -value {
    [hashtable]$modules =
    @{
        modules   = New-Icinga-Monitoring -ListModules $TRUE;
        execution = $this.GetExecutionTime();
    };

    $this.Response.setContent($modules);
    $this.SendOkResponse();
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'IsUrlPathValid' -value {
    param([int]$Index);

    [string]$path = $this.Message.base.segments[$Index];

    if ([string]::IsNullOrEmpty($path) -eq $TRUE) {
        return 'default';
    }

    return $path.Replace('/', '');
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'SendOkResponse' -value {
    $this.Network.WriteMessage(
        $this.Response.Compile()
    );
    $this.Close();
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'SendInternalServerError' -value {
    $this.Response.InternalServerError();
    $this.Network.WriteMessage(
        $this.Response.Compile()
    );
    $this.Close();
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'SendAuthenticationRequired' -value {
    $this.Response.AuthenticationRequired();
    $this.Network.WriteMessage(
        $this.Response.Compile()
    );
    $this.Close();
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'SendBadRequest' -value {
    param([string]$message);

    $this.Response.CustomBadRequest($message);
    $this.Network.WriteMessage(
        $this.Response.Compile()
    );
    $this.Close();
}

$ServerProtocoll | Add-Member -membertype ScriptMethod -name 'Close' -value {
    try {
        $this.Timer.Stop();
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Debug,
            'Closing TCP Client connection'
        )
        $this.Client.Close();
        $this.Client.Dispose()
        $this.Client = $Null;
    } catch {
        # Nothing to handle. If the connection is closed already, ignore it.
    }
}

return $ServerProtocoll;