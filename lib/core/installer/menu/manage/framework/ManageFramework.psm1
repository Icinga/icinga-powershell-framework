function Show-IcingaForWindowsManagementConsoleManageFramework()
{
    $FrameworkDebug     = Get-IcingaFrameworkDebugMode;
    $IcingaService      = Get-Service 'icingapowershell' -ErrorAction SilentlyContinue;
    $AdminShell         = $global:Icinga.InstallWizard.AdminShell;
    $ServiceStatus      = $null;

    if ($null -ne $IcingaService) {
        $ServiceStatus = $IcingaService.Status;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows:' `
        -Entries @(
            @{
                'Caption'  = 'Manage background daemons';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageBackgroundDaemons';
                'Help'     = 'Allows you to manage Icinga for Windows background daemons';
                'Disabled' = ($null -eq (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue));
            },
            @{
                'Caption'  = ([string]::Format('Framework Debug Mode: {0}', (& { if ($FrameworkDebug) { 'Enabled' } else { 'Disabled' } } )));
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Disable or enable the Icinga PowerShell Framework debug mode';
                'Disabled' = $FALSE;
                'Action'   = @{
                    'Command'   = 'Invoke-IcingaForWindowsMangementConsoleToogleFrameworkDebug';
                    'Arguments' = @{ };
                }
            },
            @{
                'Caption' = 'Update Framework Code Cache';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'    = 'Updates the Icinga PowerShell Framework Code Cache';
                'Action'  = @{
                    'Command'   = 'Write-IcingaFrameworkCodeCache';
                    'Arguments' = @{ };
                }
            },
            @{
                'Caption'  = 'Allow untrusted certificate communication (this session only)';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Enables the Icinga untrusted certificate validation, allowing you to communicate with web servers which ships with a self-signed certificate not installed on this system. This applies only to this PowerShell session and is not permanent. Might be helpful in case you want to connect to the Icinga Director and the SSL is not trusted by this host';
                'Disabled' = $FALSE
                'Action'   = @{
                    'Command'   = 'Enable-IcingaUntrustedCertificateValidation';
                    'Arguments' = @{ };
                }
            },
            @{
                'Caption'  = 'Configure experimental features';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleFrameworkExperimental';
                'Help'     = 'Allows you to manage experimental features for Icinga for Windows';
                'Disabled' = $FALSE
            },
            @{
                'Caption'  = 'Start Icinga for Windows Service';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Allows you to start the Icinga for Windows Service if the service is not running';
                'Disabled' = ($null -eq $IcingaService -Or $ServiceStatus -eq 'Running' -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Start-Service';
                    'Arguments' = @{ '-Name' = 'icingapowershell'; };
                }
            },
            @{
                'Caption'  = 'Stop Icinga for Windows Service';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Allows you to stop the Icinga for Windows Service if the service is not running';
                'Disabled' = ($null -eq $IcingaService -Or $ServiceStatus -ne 'Running' -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Stop-Service';
                    'Arguments' = @{ '-Name' = 'icingapowershell'; };
                }
            },
            @{
                'Caption'  = 'Restart Icinga for Windows Service';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Allows you to restart the Icinga for Windows Service if the service is installed';
                'Disabled' = ($null -eq $IcingaService -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Restart-Service';
                    'Arguments' = @{ '-Name' = 'icingapowershell'; };
                }
            }
        );
}
