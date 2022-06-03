function Show-IcingaForWindowsMenuManageTroubleshooting()
{
    $IcingaAgentService = Get-Service 'icinga2' -ErrorAction SilentlyContinue;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Troubleshooting options for problems:' `
        -Entries @(
            @{
                'Caption'   = 'Flush Icinga Agent API directory (Restarts service)';
                'Command'   = 'Show-IcingaForWindowsMenuManageTroubleshooting';
                'Help'      = 'Allows you to flush the Icinga Agent API directory for cleanup. This will restart the Icinga Agent service';
                'AdminMenu' = $TRUE;
                'Action'    = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption'      = 'Flush Icinga Agent API Directory (Restarts Service)';
                        '-Command'      = 'Clear-IcingaAgentApiDirectory';
                        '-CmdArguments' = @{
                            '-Force' = $TRUE;
                        }
                    }
                }
            },
            @{
                'Caption' = 'Update Icinga for Windows cache';
                'Command' = 'Show-IcingaForWindowsMenuManageTroubleshooting';
                'Help'    = 'Updates the Icinga for Windows Code Cache by re-compiling every module to ensure nothing is missing and up-to-date';
                'Action'  = @{
                    'Command' = 'Write-IcingaFrameworkCodeCache';
                }
            },
            @{
                'Caption' = 'Install Icinga for Windows certificate';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'    = 'Uses the Icinga Agent certificate on this system to create a certificate for Icinga for Windows, which is required inside a JEA context in case the REST-Api feature is used, as the background daemon will be unable to perform certain actions requires for using the certificate otherwise';
                'Action'  = @{
                    'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                    'Arguments' = @{
                        '-Caption' = 'Install Icinga for Windows certificate';
                        '-Command' = 'Install-IcingaForWindowsCertificate';
                    }
                }
            },
            @{
                'Caption'        = 'Repair Icinga Agent service';
                'Command'        = 'Show-IcingaForWindowsMenuManageTroubleshooting';
                'Help'           = 'Allows to repair the Icinga Agent service in case it was removed or broke during installation/upgrade';
                'Disabled'       = ($null -ne $IcingaAgentService);
                'DisabledReason' = 'The Icinga Agent service is already present';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command' = 'Repair-IcingaService';
                }
            },
            @{
                'Caption'        = 'Repair Icinga Agent state file';
                'Command'        = 'Show-IcingaForWindowsMenuManageTroubleshooting';
                'Help'           = 'Allows to repair the Icinga Agent state file, in case the file is corrupt';
                'Disabled'       = (Test-IcingaStateFile);
                'DisabledReason' = 'The Icinga Agent state file is healthy';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command' = 'Repair-IcingaStateFile';
                }
            },
            @{
                'Caption'  = 'Allow untrusted certificate communication (This session)';
                'Command'  = 'Show-IcingaForWindowsMenuManageTroubleshooting';
                'Help'     = 'Enables the Icinga untrusted certificate validation, allowing you to communicate with web servers which ships with a self-signed certificate not installed on this system. This applies only to this PowerShell session and is not permanent. Might be helpful in case you want to connect to the Icinga Director and the SSL is not trusted by this host';
                'Disabled' = $FALSE
                'Action'   = @{
                    'Command' = 'Enable-IcingaUntrustedCertificateValidation';
                }
            }
        );
}
