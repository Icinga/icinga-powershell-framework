function Show-IcingaForWindowsMenuRemoveComponents()
{
    [array]$UninstallFeatures   = @();
    $AgentInstalled             = (Get-IcingaAgentInstallation).Installed;
    $PowerShellServiceInstalled = Get-IcingaWindowsServiceStatus -Service 'icingapowershell';
    $IcingaWindowsServiceData   = Get-IcingaForWindowsServiceData;
    $ModuleList                 = Get-Module 'icinga-powershell-*' -ListAvailable;

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga Agent';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'Will remove the Icinga Agent from this system. Please note that this option will leave content inside "ProgramData", like certificates, alone'
        'Disabled' = (-Not $AgentInstalled);
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
        'Caption'  = 'Uninstall Icinga Agent including ProgramData';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'Will remove the Icinga Agent from this system. Please note that this option will leave content inside "ProgramData", like certificates, alone'
        'Disabled' = (-Not (Test-Path -Path (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2')));
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga Agent including ProgramData';;
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
        'Disabled' = (-Not $PowerShellServiceInstalled.Present);
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
        'Caption'  = 'Uninstall Icinga for Windows Service including binary';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'This will remove the icingapowershell service for Icinga for Windows if installed and the service binary including the folder, if empty afterwards'
        'Disabled' = (-Not (Test-Path $IcingaWindowsServiceData.Directory));
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga for Windows Service including binary';
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
        $Caption       = ([string]::Format('Uninstall "{0}"', $ComponentName));

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

    $UninstallFeatures += @{
        'Caption' = 'Uninstall all components';
        'Command' = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'    = 'This will remove all current installed components of Icinga for Windows, but will keep the Framework installed'
        'Action'  = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall all components';
                '-Command'      = 'Uninstall-IcingaForWindows';
                '-CmdArguments' = @{
                    '-Force'          = $TRUE;
                    '-ComponentsOnly' = $TRUE;
                }
            }
        }
    }

    $UninstallFeatures += @{
        'Caption' = 'Uninstall Icinga for Windows';
        'Command' = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'    = 'This will remove everything installed and configured by Icinga for Windows on this machine'
        'Action'  = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga for Windows';
                '-Command'      = 'Uninstall-IcingaForWindows';
                '-CmdArguments' = @{
                    '-Force' = $TRUE;
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Uninstall Icinga for Windows components. Select an entry to continue:' `
        -Entries $UninstallFeatures;
}
