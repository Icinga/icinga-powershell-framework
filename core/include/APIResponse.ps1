$APIResponse = New-Object -TypeName PSObject;

$APIResponse | Add-Member -membertype NoteProperty -name 'static'     -value $FALSE;
$APIResponse | Add-Member -membertype NoteProperty -name 'statuscode' -value 200;
$APIResponse | Add-Member -membertype NoteProperty -name 'message'    -value '';
$APIResponse | Add-Member -membertype NoteProperty -name 'content'    -value $null;
$APIResponse | Add-Member -membertype NoteProperty -name 'authheader' -value '';

$APIResponse | Add-Member -membertype ScriptMethod -name 'setContent' -value {
    param([object]$content);

    $this.content = $content;
}

$APIResponse | Add-Member -membertype ScriptMethod -name 'CustomBadRequest' -value {
    param([string]$message);

    $this.statuscode = 400;
    $this.message    = $message;
}

$APIResponse | Add-Member -membertype ScriptMethod -name 'InternalServerError' -value {
    $this.statuscode = 500;
    $this.message    = 'An internal server error occured while parsing your request.';
}

$APIResponse | Add-Member -membertype ScriptMethod -name 'HTTPSRequired' -value {
    $this.statuscode = 403;
    $this.message    = 'This API only supports connections over HTTPS.';
}

$APIResponse | Add-Member -membertype ScriptMethod -name 'AuthenticationRequired' -value {
    $this.statuscode = 401;
    $this.message    = 'You require to login in order to access this ressource.';
    $this.authheader = [string]::Format(
        'WWW-Authenticate: Basic realm="Icinga Windows Daemon"{0}',
        "`r`n"
    );
}

$APIResponse | Add-Member -membertype ScriptMethod -name 'CompileMessage' -value {
    # If our message is empty, do nothing
    if ([string]::IsNullOrEmpty($this.message)) {
        return;
    }

    # In case we assigned custom content, do not override this content
    if ($this.content -ne $null) {
        return;
    }

    $this.content = @{
        response = $this.statuscode;
        message  = $this.message;
    };
}

$APIResponse | Add-Member -membertype ScriptMethod -name 'Compile' -value {

    $this.CompileMessage();

    [string]$ContentLength = '';
    [string]$HTMLContent   = '';
    if ($this.content -ne $null) {
        $json         = ConvertTo-Json $this.content -Depth 100 -Compress;
        $bytes        = [System.Text.Encoding]::UTF8.GetBytes($json);
        $HTMLContent  = [System.Text.Encoding]::UTF8.GetString($bytes);
        if ($bytes.Length -gt 0) {
            $ContentLength = [string]::Format(
                'Content-Length: {0}{1}',
                $bytes.Length,
                "`r`n"
            );
        }
    }

    return -Join(
        [string]::Format(
            'HTTP/1.1 {0} {1}{2}',
            $this.statuscode,
            $Icinga2.Enums.HttpStatusCodes.$this.statuscode,
            "`r`n"
        ),
        [string]::Format(
            'Server: {0}{1}',
            (Get-WmiObject Win32_ComputerSystem).Name,
            "`r`n"
        ),
        [string]::Format(
            'Content-Type: application/json{0}',
            "`r`n"
        ),
        $this.authheader,
        $ContentLength,
        "`r`n",
        $HTMLContent
    );
}

return $APIResponse;