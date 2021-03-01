function Show-IcingaForWindowsMenuManageIcingaAgent()
{
    $IcingaService = Get-Service 'icinga2' -ErrorAction SilentlyContinue;
    $AdminShell    = $global:Icinga.InstallWizard.AdminShell;
    $ServiceStatus = $null;

    if ($null -ne $IcingaService) {
        $ServiceStatus = $IcingaService.Status;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga Agent:' `
        -Entries @(
            @{
                'Caption'  = 'Manage Features';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgentFeatures';
                'Help'     = 'Allows you to install Icinga for Windows with all required components and options';
                'Disabled' = ($null -eq $IcingaService -Or (-Not $AdminShell));
            },
            @{
                'Caption'  = 'Reconfigure Installation';
                'Command'  = 'Invoke-IcingaForWindowsManagementConsoleReconfigureAgent';
                'Help'     = 'Load the current applied configuration for your Icinga Agent and modify the values';
                'Disabled' = ($null -eq (Get-IcingaPowerShellConfig -Path 'Framework.Config.Live'));
            },
            @{
                'Caption'  = 'Read Icinga Agent Log File';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows to read the Icinga Agent log file in case the "mainlog" feature of the Icinga Agent is enabled';
                'Disabled' = ((-Not $AdminShell) -Or -Not (Test-IcingaAgentFeatureEnabled -Feature 'mainlog'));
                'Action'   = @{
                    'Command'   = 'Start-Process';
                    'Arguments' = @{ '-FilePath' = 'powershell.exe'; '-ArgumentList' = "-Command  `"&{ icinga { Read-IcingaAgentLogFile; }; }`"" };
                }
            },
            @{
                'Caption'  = 'Read Icinga Debug Log File';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows to read the Icinga Agent debug log file in case the "debuglog" feature of the Icinga Agent is enabled';
                'Disabled' = ((-Not $AdminShell) -Or -Not (Test-IcingaAgentFeatureEnabled -Feature 'debuglog'));
                'Action'   = @{
                    'Command'   = 'Start-Process';
                    'Arguments' = @{ '-FilePath' = 'powershell.exe'; '-ArgumentList' = "-Command  `"&{ icinga { Read-IcingaAgentDebugLogFile; }; }`"" };
                }
            },
            @{
                'Caption'  = 'Flush API directory (will restart Agent)';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to flush the Icinga Agent API directory for cleanup. This will restart the Icinga Agent';
                'Disabled' = ($null -eq $IcingaService -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Clear-IcingaAgentApiDirectory';
                    'Arguments' = @{ '-Force' = $TRUE };
                }
            },
            @{
                'Caption'  = 'Start Icinga Agent';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to start the Icinga Agent if the service is not running';
                'Disabled' = ($null -eq $IcingaService -Or $ServiceStatus -eq 'Running' -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Start-Service';
                    'Arguments' = @{ '-Name' = 'icinga2'; };
                }
            },
            @{
                'Caption'  = 'Stop Icinga Agent';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to stop the Icinga Agent if the service is not running';
                'Disabled' = ($null -eq $IcingaService -Or $ServiceStatus -ne 'Running' -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Stop-Service';
                    'Arguments' = @{ '-Name' = 'icinga2'; };
                }
            },
            @{
                'Caption'  = 'Restart Icinga Agent';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to restart the Icinga Agent if the service is installed';
                'Disabled' = ($null -eq $IcingaService -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Restart-Service';
                    'Arguments' = @{ '-Name' = 'icinga2'; };
                }
            }
        );
}
