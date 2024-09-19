function Show-IcingaForWindowsMenuManageIcingaForWindowsServices()
{
    $IcingaAgentService      = Get-Service 'icinga2' -ErrorAction SilentlyContinue;
    $IcingaAgentStatus       = 'Not Installed';
    $IcingaForWindowsService = Get-Service 'icingapowershell' -ErrorAction SilentlyContinue;
    $IcingaForWindowsStatus  = 'Not Installed';

    if ($null -ne $IcingaAgentService) {
        $IcingaAgentStatus = $IcingaAgentService.Status;
    }

    if ($null -ne $IcingaForWindowsService) {
        $IcingaForWindowsStatus = $IcingaForWindowsService.Status;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header ([string]::Format('Manage Services:{0}=> Icinga Agent Service: {1}{0}=> Icinga for Windows Service: {2}', (New-IcingaNewLine), $IcingaAgentStatus, $IcingaForWindowsStatus)) `
        -Entries @(
            @{
                'Caption'        = 'Start Icinga Agent Service';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Allows you to start the Icinga Agent if the service is not running';
                'Disabled'       = ($null -eq $IcingaAgentService -Or $IcingaAgentStatus -eq 'Running');
                'DisabledReason' = 'The Icinga Agent service is either not installed or the service is already running';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command'   = 'Start-IcingaService';
                    'Arguments' = @{ '-Service' = 'icinga2'; };
                }
            },
            @{
                'Caption'        = 'Stop Icinga Agent Service';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Allows you to stop the Icinga Agent if the service is not running';
                'Disabled'       = ($null -eq $IcingaAgentService -Or $IcingaAgentStatus -ne 'Running');
                'DisabledReason' = 'The Icinga Agent service is either not installed or the service is not running';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command'   = 'Stop-IcingaService';
                    'Arguments' = @{ '-Service' = 'icinga2'; };
                }
            },
            @{
                'Caption'        = 'Restart Icinga Agent Service';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Allows you to restart the Icinga Agent if the service is installed';
                'Disabled'       = ($null -eq $IcingaAgentService);
                'DisabledReason' = 'The Icinga Agent service is not installed';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command'   = 'Restart-IcingaService';
                    'Arguments' = @{ '-Service' = 'icinga2'; };
                }
            },
            @{
                'Caption'        = 'Repair Icinga Agent Service';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Allows to repair the Icinga Agent service in case it was removed or broke during installation/upgrade';
                'Disabled'       = ($null -ne $IcingaAgentService);
                'DisabledReason' = 'The Icinga Agent service is already present';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command' = 'Repair-IcingaService';
                }
            },
            @{
                'Caption'        = 'Start Icinga for Windows Service';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Allows you to start the Icinga for Windows Service if the service is not running';
                'Disabled'       = ($null -eq $IcingaForWindowsService -Or $IcingaForWindowsStatus -eq 'Running');
                'DisabledReason' = 'The Icinga for Windows service is either not installed or already running';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command'   = 'Start-IcingaService';
                    'Arguments' = @{ '-Service' = 'icingapowershell'; };
                }
            },
            @{
                'Caption'        = 'Stop Icinga for Windows Service';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Allows you to stop the Icinga for Windows Service if the service is not running';
                'Disabled'       = ($null -eq $IcingaForWindowsService -Or $IcingaForWindowsStatus -ne 'Running');
                'DisabledReason' = 'The Icinga for Windows service is either not installed or not running';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command' = 'Stop-IcingaForWindows';
                }
            },
            @{
                'Caption'        = 'Restart Icinga for Windows Service';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Allows you to restart the Icinga for Windows Service if the service is installed';
                'Disabled'       = ($null -eq $IcingaForWindowsService);
                'DisabledReason' = 'The Icinga for Windows service is not installed';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command' = 'Restart-IcingaForWindows';
                }
            },
            @{
                'Caption'        = 'Enable recovery settings for services';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Enables automatic service recovery for the Icinga Agent and Icinga for Windows service, in case the server terminates itself because of errors';
                'Disabled'       = ($null -eq $IcingaForWindowsService -And $null -eq $IcingaAgentService);
                'DisabledReason' = 'Neither the Icinga Agent nor the Icinga for Windows service are installed';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command' = 'Enable-IcingaServiceRecovery';
                }
            },
            @{
                'Caption'        = 'Disable recovery settings for services';
                'Command'        = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'           = 'Disables automatic service recovery for the Icinga Agent and Icinga for Windows service, in case the server terminates itself because of errors';
                'Disabled'       = ($null -eq $IcingaForWindowsService -And $null -eq $IcingaAgentService);
                'DisabledReason' = 'Neither the Icinga Agent nor the Icinga for Windows service are installed';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command' = 'Disable-IcingaServiceRecovery';
                }
            }
        );
}
