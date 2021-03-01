function Show-IcingaForWindowsManagementConsoleRegisterBackgroundDaemons()
{
    [array]$AvailableDaemons = @();
    $ModuleList              = Get-Module 'icinga-powershell-*' -ListAvailable;

    $AvailableDaemons += @{
        'Caption'  = 'Register background daemon "Start-IcingaServiceCheckDaemon"';
        'Command'  = 'Show-IcingaForWindowsManagementConsoleRegisterBackgroundDaemons';
        'Help'     = ((Get-Help 'Start-IcingaServiceCheckDaemon' -Full).Description.Text);
        'Disabled' = $FALSE;
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Register background daemon "Start-IcingaServiceCheckDaemon"';
                '-Command'      = 'Register-IcingaBackgroundDaemon';
                '-CmdArguments' = @{
                    '-Command' = 'Start-IcingaServiceCheckDaemon';
                }
            }
        }
    }

    foreach ($module in $ModuleList) {

        $ModuleInfo = $null;

        Import-LocalizedData -BaseDirectory (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath $module.Name) -FileName ([string]::Format('{0}.psd1', $module.Name)) -BindingVariable ModuleInfo -ErrorAction SilentlyContinue;

        if ($null -eq $ModuleInfo -Or $null -eq $ModuleInfo.PrivateData -Or $null -eq $ModuleInfo.PrivateData.Type -Or ([string]::IsNullOrEmpty($ModuleInfo.PrivateData.Type)) -Or $ModuleInfo.PrivateData.Type -ne 'daemon' -Or $null -eq $ModuleInfo.PrivateData.Function -Or ([string]::IsNullOrEmpty($ModuleInfo.PrivateData.Function))) {
            continue;
        }

        $HelpObject  = Get-Help ($ModuleInfo.PrivateData.Function) -Full -ErrorAction SilentlyContinue;
        $HelpText    = '';
        $Caption     = [string]::Format('Register background daemon "{0}"', ($ModuleInfo.PrivateData.Function));

        if ($null -ne $HelpObject) {
            $HelpText = $HelpObject.Description.Text;
        }

        $AvailableDaemons += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsManagementConsoleRegisterBackgroundDaemons';
            'Help'     = $HelpText;
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = $Caption;
                    '-Command'      = 'Register-IcingaBackgroundDaemon';
                    '-CmdArguments' = @{
                        '-Command' = $ModuleInfo.PrivateData.Function;
                    }
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Register Icinga for Windows background daemon:' `
        -Entries $AvailableDaemons;
}
