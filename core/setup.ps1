param(
    [bool]$IsAgentIntalled            = $FALSE
)

function ClassSetup()
{
    param(
        [bool]$IsAgentIntalled            = $FALSE
    );

    $instance = New-Object -TypeName PSObject;

    $instance | Add-Member -membertype NoteProperty -name 'BaseDirectory' -value (Join-Path $Icinga2.App.RootPath -ChildPath 'agent');

    $instance | Add-Member -membertype ScriptMethod -name 'Init' -value {
        $IsInstalled = Get-Icinga-Config -Key 'setup.installed';

        if ($IsAgentIntalled) {
            if ($IsInstalled -eq $FALSE -Or $IsInstalled -eq $null) {
                return 0;
            }
        }

        $this.CreateDirectories('config');
        $this.CreateDirectories('state');

        if ($IsInstalled -eq $FALSE -Or $IsInstalled -eq $null) {
            $this.InstallEventLog();
            $this.CreateConfig();
        }

        # At this point for this module, we require to return 1 as 'true'
        return 1;
    }

    $instance | Add-Member -membertype ScriptMethod -name 'CreateDirectories' -value {
        param([string]$directory);

        [string]$path = Join-Path $this.BaseDirectory -ChildPath $directory;
        if (-Not (Test-Path $path)) {
            New-Item $path -ItemType Directory | Out-Null;
            $Icinga2.Log.Write(
                $Icinga2.Enums.LogState.Info,
                ([string]::Format('Creating new directory "{0}"', $path))
            );
        }
    }

    $instance | Add-Member -membertype ScriptMethod -name 'InstallEventLog' -value {
        try {
            New-EventLog -LogName Application -Source ($Icinga2.Service.servicedisplayname) -ErrorAction Stop;
            $Icinga2.Log.WriteConsole(
                $Icinga2.Enums.LogState.Info,
                [string]::Format(
                    'Successfully installed EventLog "{0}" for this module',
                    $Icinga2.Service.servicedisplayname
                )
            );
         } catch {
            $Icinga2.Log.WriteConsole(
                $Icinga2.Enums.LogState.Warning,
                [string]::Format(
                    'EventLog for "{0}" is already installed.',
                    $Icinga2.Service.servicedisplayname
                )
            );
        }
    }

    $instance | Add-Member -membertype ScriptMethod -name 'CreateConfig' -value {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Info,
            '### Installing default configuration values ###'
        );

        Set-Icinga-Config -Key 'checker.server.host'              -Value 'https://localhost/icingaweb2/windows/checkresult' | Out-Null;
        Set-Icinga-Config -Key 'checker.ssl.verify'               -Value $TRUE                                              | Out-Null;
        Set-Icinga-Config -Key 'tcp.socket.host'                  -Value 'localhost'                                        | Out-Null;
        Set-Icinga-Config -Key 'tcp.socket.port'                  -Value '5891'                                             | Out-Null;
        Set-Icinga-Config -Key 'service.name'                     -Value 'icinga2winservice'                                | Out-Null;
        Set-Icinga-Config -Key 'service.displayname'              -Value 'Icinga 2 Windows Service'                         | Out-Null;
        Set-Icinga-Config -Key 'setup.installed'                  -Value $TRUE                                              | Out-Null;
        Set-Icinga-Config -Key 'certstore.name'                   -Value 'My'                                               | Out-Null;
        Set-Icinga-Config -Key 'certstore.location'               -Value 'LocalMachine'                                     | Out-Null;
        Set-Icinga-Config -Key 'certstore.certificate.name'       -Value ''                                                 | Out-Null;
        Set-Icinga-Config -Key 'certstore.certificate.thumbprint' -Value ''                                                 | Out-Null;
        Set-Icinga-Config -Key 'logger.directory'                 -Value ''                                                 | Out-Null;
        Set-Icinga-Config -Key 'logger.debug'                     -Value $FALSE                                             | Out-Null;
        Set-Icinga-Config -Key 'authentication.enabled'           -Value $FALSE                                             | Out-Null;
        Set-Icinga-Config -Key 'authentication.user'              -Value ''                                                 | Out-Null;
        Set-Icinga-Config -Key 'authentication.domain'            -Value ''                                                 | Out-Null;
    }

    return $instance.Init();
}

return ClassSetup -IsAgentIntalled $IsAgentIntalled;