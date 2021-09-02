function Show-IcingaForWindowsManagementConsoleManageFramework()
{
    $FrameworkDebug = Get-IcingaFrameworkDebugMode;
    $IcingaService  = Get-Service 'icingapowershell' -ErrorAction SilentlyContinue;
    $AdminShell     = $global:Icinga.InstallWizard.AdminShell;
    $ServiceStatus  = $null;
    $JEADisabled    = $FALSE;

    if ($PSVersionTable.PSVersion -lt (New-IcingaVersionObject -Version 5, 0) -Or $AdminShell -eq $FALSE) {
        $JEADisabled = $TRUE;
    }

    if ($null -ne $IcingaService) {
        $ServiceStatus = $IcingaService.Status;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows:' `
        -Entries @(
            @{
                'Caption'        = 'Manage background daemons';
                'Command'        = 'Show-IcingaForWindowsManagementConsoleManageBackgroundDaemons';
                'Help'           = 'Allows you to manage Icinga for Windows background daemons';
                'Disabled'       = ($null -eq (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue));
                'DisabledReason' = 'Icinga for Windows service is not installed';
            },
            @{
                'Caption' = 'Manage Icinga Repositories';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageIcingaRepositories';
                'Help'    = 'Allows you to manage Icinga for Windows repositories';
            },
            @{
                'Caption'        = 'Manage JEA profile';
                'Command'        = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'           = 'Allows you to manage Icinga for Windows JEA profile';
                'Disabled'       = $JEADisabled;
                'DisabledReason' = ([string]::Format('PowerShell version "{0}" is lower than 5.0 or you are not inside an administrative shell', $PSVersionTable.PSVersion.ToString(2)));
            },
            @{
                'Caption'  = ([string]::Format('Framework Debug Mode: {0}', (& { if ($FrameworkDebug) { 'Enabled' } else { 'Disabled' } } )));
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Disable or enable the Icinga PowerShell Framework debug mode';
                'Disabled' = $FALSE;
                'Action'   = @{
                    'Command' = 'Invoke-IcingaForWindowsMangementConsoleToogleFrameworkDebug';
                }
            },
            @{
                'Caption' = 'Update Framework Code Cache';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'    = 'Updates the Icinga PowerShell Framework Code Cache';
                'Action'  = @{
                    'Command' = 'Write-IcingaFrameworkCodeCache';
                }
            },
            @{
                'Caption'  = 'Allow untrusted certificate communication (this session only)';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Enables the Icinga untrusted certificate validation, allowing you to communicate with web servers which ships with a self-signed certificate not installed on this system. This applies only to this PowerShell session and is not permanent. Might be helpful in case you want to connect to the Icinga Director and the SSL is not trusted by this host';
                'Disabled' = $FALSE
                'Action'   = @{
                    'Command' = 'Enable-IcingaUntrustedCertificateValidation';
                }
            },
            @{
                'Caption'  = 'Configure experimental features';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleFrameworkExperimental';
                'Help'     = 'Allows you to manage experimental features for Icinga for Windows';
                'Disabled' = $FALSE
            },
            @{
                'Caption'        = 'Start Icinga for Windows Service';
                'Command'        = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'           = 'Allows you to start the Icinga for Windows Service if the service is not running';
                'Disabled'       = ($null -eq $IcingaService -Or $ServiceStatus -eq 'Running' -Or (-Not $AdminShell));
                'DisabledReason' = 'The service is either not installed, already running or you are not inside an administrative shell';
                'Action'         = @{
                    'Command'   = 'Start-Service';
                    'Arguments' = @{ '-Name' = 'icingapowershell'; };
                }
            },
            @{
                'Caption'        = 'Stop Icinga for Windows Service';
                'Command'        = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'           = 'Allows you to stop the Icinga for Windows Service if the service is not running';
                'Disabled'       = ($null -eq $IcingaService -Or $ServiceStatus -ne 'Running' -Or (-Not $AdminShell));
                'DisabledReason' = 'The service is either not installed, already stopped or you are not inside an administrative shell';
                'Action'         = @{
                    'Command' = 'Stop-IcingaWindowsService';
                }
            },
            @{
                'Caption'        = 'Restart Icinga for Windows Service';
                'Command'        = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'           = 'Allows you to restart the Icinga for Windows Service if the service is installed';
                'Disabled'       = ($null -eq $IcingaService -Or (-Not $AdminShell));
                'DisabledReason' = 'The service is either not installed or you are not inside an administrative shell';
                'Action'         = @{
                    'Command' = 'Restart-IcingaWindowsService';
                }
            }
        );
}
