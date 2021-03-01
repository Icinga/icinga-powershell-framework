function Show-IcingaForWindowsManagementConsoleUnregisterBackgroundDaemons()
{
    [array]$RegisteredDaemons = @();

    $BackgroundDaemons = Get-IcingaBackgroundDaemons;

    foreach ($daemon in $BackgroundDaemons.Keys) {
        $DaemonValue = $BackgroundDaemons[$daemon];
        $HelpObject  = Get-Help $daemon -Full -ErrorAction SilentlyContinue;
        $HelpText    = '';
        $Caption     = [string]::Format('Unregister background daemon "{0}"', $daemon);

        if ($null -ne $HelpObject) {
            $HelpText = $HelpObject.Description.Text;
        }

        $RegisteredDaemons += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsManagementConsoleUnregisterBackgroundDaemons';
            'Help'     = $HelpText;
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = $Caption;
                    '-Command'      = 'Unregister-IcingaBackgroundDaemon';
                    '-CmdArguments' = @{
                        '-BackgroundDaemon' = $daemon;
                    }
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Unregister Icinga for Windows background daemon:' `
        -Entries $RegisteredDaemons;
}
