function Show-IcingaForWindowsMenuRemoveComponents()
{

    [array]$UninstallFeatures   = @();
    $AgentInstalled             = Get-Service -Name 'icinga2' -ErrorAction SilentlyContinue;
    $PowerShellServiceInstalled = Get-Service -Name 'icingapowershell' -ErrorAction SilentlyContinue;
    $IcingaWindowsServiceData   = Get-IcingaForWindowsServiceData;
    $ModuleList                 = Get-Module 'icinga-powershell-*' -ListAvailable;

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga Agent';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'Will remove the Icinga Agent from this system. Please note that this option will leave content inside "ProgramData", like certificates, alone'
        'Disabled' = ($null -eq $AgentInstalled);
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga Agent';
                '-Command'      = 'Uninstall-IcingaComponent';
                '-CmdArguments' = @{
                    '-Name' = 'agent';
                }
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
                '-Command'      = 'Uninstall-IcingaComponent';
                '-CmdArguments' = @{
                    '-Name'               = 'agent';
                    '-RemovePackageFiles' = $TRUE;
                }
            }
        }
    }

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga for Windows Service';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'This will remove the icingapowershell service for Icinga for Windows if installed'
        'Disabled' = ($null -eq $PowerShellServiceInstalled);
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga for Windows service';
                '-Command'      = 'Uninstall-IcingaComponent';
                '-CmdArguments' = @{
                    '-Name' = 'service';
                }
            }
        }
    }

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga for Windows Service (include files)';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'This will remove the icingapowershell service for Icinga for Windows if installed and the service binary including the folder, if empty afterwards'
        'Disabled' = (-Not (Test-Path $IcingaWindowsServiceData.Directory));
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga for Windows service (include files)';
                '-Command'      = 'Uninstall-IcingaComponent';
                '-CmdArguments' = @{
                    '-Name'               = 'service';
                    '-RemovePackageFiles' = $TRUE;
                }
            }
        }
    }

    foreach ($module in $ModuleList) {
        $ComponentName = $module.Name.Replace('icinga-powershell-', '');
        $Caption       = ([string]::Format('Uninstall component "{0}"', $ComponentName));

        if ($ComponentName -eq 'framework' -Or $ComponentName -eq 'service' -Or $ComponentName -eq 'agent') {
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
                    '-Command'      = 'Uninstall-IcingaComponent';
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
