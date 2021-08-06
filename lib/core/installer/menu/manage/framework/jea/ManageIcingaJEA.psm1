function Show-IcingaForWindowsManagementConsoleManageJEA()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows JEA configuration:' `
        -Entries @(
            @{
                'Caption' = 'Install JEA profile with managed user "icinga"';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Will create a managed user called "icinga", updates the services "icinga2" and "icingapowershell" with the new user and creates a JEA profile based on installed modules';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption' = 'Install JEA profile with managed user "icinga"';
                        '-Command' = 'Install-IcingaSecurity';
                    }
                }
            },
            @{
                'Caption' = 'Install/Update JEA profile';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Installs or updates the JEA profile for Icinga for Windows for the current user assigned to the "icinga2" service';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption' = 'Install/Update JEA profile';
                        '-Command' = 'Install-IcingaJEAProfile';
                    }
                }
            },
            @{
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
            },
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
                'Caption' = 'Uninstall JEA profile';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Uninstalls the JEA profile from this system';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption' = 'Uninstall JEA profile';
                        '-Command' = 'Uninstall-IcingaJEAProfile';
                    }
                }
            },
            @{
                'Caption' = 'Rebuild Icinga PowerShell Framework dependency cache';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Rebuilds the Icinga for Windows Framework dependency cache for JEA profile generation';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption'      = 'Rebuild Icinga PowerShell Framework dependency cache';
                        '-Command'      = 'Get-IcingaJEAConfiguration';
                        '-CmdArguments' = @{
                            '-RebuildFramework' = $TRUE;
                        }
                    }
                }
            }
        );
}
