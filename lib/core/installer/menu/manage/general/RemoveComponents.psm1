function Show-IcingaForWindowsMenuRemoveComponents()
{

    [array]$UninstallFeatures = @();
    $AgentInstalled           = Get-Service -Name 'icinga2' -ErrorAction SilentlyContinue;
    $ModuleList               = Get-Module 'icinga-powershell-*' -ListAvailable;

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga Agent';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'Will remove the Icinga Agent from this system. Please note that this option will leave content inside "ProgramData", like certificates, alone'
        'Disabled' = ($null -eq $AgentInstalled);
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption' = 'Uninstall Icinga Agent';
                '-Command' = 'Uninstall-IcingaAgent';
            }
        }
    }

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga Agent (include ProgramData)';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'Will remove the Icinga Agent from this system. Please note that this option will leave content inside "ProgramData", like certificates, alone'
        'Disabled' = (-Not (Test-Path -Path (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2')));
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga Agent (include ProgramData)';
                '-Command'      = 'Uninstall-IcingaAgent';
                '-CmdArguments' = @{
                    '-RemoveDataFolder' = $TRUE;
                }
            }
        }
    }

    foreach ($module in $ModuleList) {
        $ComponentName = $module.Name.Replace('icinga-powershell-', '');
        $Caption       = ([string]::Format('Uninstall component "{0}"', $ComponentName));

        if ($ComponentName -eq 'framework') {
            continue;
        }

        $UninstallFeatures += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
            'Help'     = ([string]::Format('This will remove the Icinga for Windows component "{0}" from this host', $ComponentName));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = $Caption;
                    '-Command'      = 'Uninstall-IcingaFrameworkComponent';
                    '-CmdArguments' = @{
                        '-Name' = $ComponentName;
                    }
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Uninstall Icinga for Windows components. Select an entry to continue:' `
        -Entries $UninstallFeatures;
}
