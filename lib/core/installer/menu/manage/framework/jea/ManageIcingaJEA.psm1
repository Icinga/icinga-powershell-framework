function Show-IcingaForWindowsManagementConsoleManageJEA()
{
    [bool]$JEAContext = (-Not [string]::IsNullOrEmpty((Get-IcingaJEAContext)));
    $ServiceData      = Get-IcingaAgentInstallation;
    $ServiceUser      = 'No service installed';

    if ($ServiceData.Installed -eq $FALSE) {
        $ServiceData = Get-IcingaServices 'icingapowershell';
        if ($null -ne $ServiceData) {
            $ServiceUser = $ServiceData.icingapowershell.configuration.ServiceUser;
        }
    } else {
        $ServiceUser = $ServiceData.User;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header ([string]::Format('Manage Icinga for Windows JEA configuration:{0}=> Current User: {1}{0}=> JEA installed: {2}', (New-IcingaNewLine), $ServiceUser, $JEAContext)) `
        -DefaultIndex '0' `
        -Entries @(
            @{
                'Caption' = 'Install JEA profile with managed user "icinga"';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Will create a managed user called "icinga", updates the services "icinga2" and "icingapowershell" with the new user and creates a JEA profile based on installed modules';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption'      = 'Install JEA profile with managed user "icinga"';
                        '-Command'      = 'Install-IcingaSecurity';
                        '-CmdArguments' = @{
                            '-RebuildFramework' = $TRUE;
                        }
                    }
                }
            },
            @{
                'Caption' = 'Install JEA profile without managed user';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Installs the JEA profile for Icinga for Windows for the current user assigned to the "icinga2" service';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption'      = 'Install JEA profile without managed user';
                        '-Command'      = 'Install-IcingaJEAProfile';
                        '-CmdArguments' = @{
                            '-RebuildFramework' = $TRUE;
                        }
                    }
                }
            },
            @{
                'Caption' = 'Update JEA profile';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Update JEA profile';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption'      = 'Update JEA profile';
                        '-Command'      = 'Install-IcingaJEAProfile';
                        '-CmdArguments' = @{
                            '-RebuildFramework' = $TRUE;
                        }
                    }
                }
            },
            <#@{
                'Caption' = 'Install JEA profile with "ConstrainedLanguage" and managed user "icinga"';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Will create a managed user called "icinga", updates the services "icinga2" and "icingapowershell" with the new user and creates a JEA profile with "ConstrainedLanguage" based on installed modules. This is NOT recommended in case you are using the Icinga for Windows service, as it will not work in "ConstrainedLanguage" mode';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption'      = 'Install JEA profile with "ConstrainedLanguage" and managed user "icinga"';
                        '-Command'      = 'Install-IcingaSecurity';
                        '-CmdArguments' = @{
                            '-ConstrainedLanguage' = $TRUE;
                        }
                    }
                }
            },
            @{
                'Caption' = 'Install/Update JEA profile with "ConstrainedLanguage"';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Installs or updates the JEA profile for Icinga for Windows for the current user assigned to the "icinga2" service with "ConstrainedLanguage". This is NOT recommended in case you are using the Icinga for Windows service, as it will not work in "ConstrainedLanguage" mode';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption'      = 'Install/Update JEA profile with "ConstrainedLanguage"';
                        '-Command'      = 'Install-IcingaJEAProfile';
                        '-CmdArguments' = @{
                            '-ConstrainedLanguage' = $TRUE;
                        }
                    }
                }
            },#>
            @{
                'Caption' = 'Uninstall JEA profile and managed user "icinga"';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'This will uninstall the JEA profile and remove the managed user "icinga" from the system. For the services the default user "NT Authority\NetworkService" will be applied';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption' = 'Uninstall JEA profile and managed user "icinga"';
                        '-Command' = 'Uninstall-IcingaSecurity';
                    }
                }
            },
            @{
                'Caption' = 'Uninstall JEA profile without managed user';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Uninstalls the JEA profile from this system';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption' = 'Uninstall JEA profile without managed user';
                        '-Command' = 'Uninstall-IcingaJEAProfile';
                    }
                }
            }
        );
}
