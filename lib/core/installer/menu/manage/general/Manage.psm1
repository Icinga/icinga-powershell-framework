function Show-IcingaForWindowsMenuManage()
{
    $AgentInstalled = (Get-IcingaAgentInstallation).Installed;
    $JEADisabled    = $FALSE;

    if ($PSVersionTable.PSVersion -lt (New-IcingaVersionObject -Version 5, 0)) {
        $JEADisabled = $TRUE;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Icinga for Windows Settings:' `
        -Entries @(
            @{
                'Caption'   = 'Services';
                'Command'   = 'Show-IcingaForWindowsMenuManageIcingaForWindowsServices';
                'Help'      = 'Allows you to manage the Icinga Agent and Icinga for Windows service';
                'Disabled'  = (-Not $AgentInstalled -And -Not (Get-IcingaWindowsServiceStatus -Service 'icingapowershell').Present);
                'AdminMenu' = $TRUE;
            },
            @{
                'Caption'   = 'Icinga Agent Features';
                'Command'   = 'Show-IcingaForWindowsMenuManageIcingaAgentFeatures';
                'Help'      = 'Allows you to install Icinga for Windows with all required components and options';
                'Disabled'  = (-Not $AgentInstalled);
                'AdminMenu' = $TRUE;
            },
            @{
                'Caption'        = 'Background Daemons';
                'Command'        = 'Show-IcingaForWindowsManagementConsoleManageBackgroundDaemons';
                'Help'           = 'Allows you to manage Icinga for Windows background daemons';
                'Disabled'       = (-Not (Get-IcingaWindowsServiceStatus -Service 'icingapowershell').Present);
                'DisabledReason' = 'Icinga for Windows service is not installed';
            },
            @{
                'Caption' = 'Repositories';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageIcingaRepositories';
                'Help'    = 'Allows you to manage Icinga for Windows repositories';
            },
            @{
                'Caption'        = 'JEA';
                'Command'        = 'Show-IcingaForWindowsManagementConsoleManageJEA';
                'Help'           = 'Allows you to manage Icinga for Windows JEA profile';
                'Disabled'       = $JEADisabled;
                'DisabledReason' = ([string]::Format('PowerShell version "{0}" is lower than 5.0 or you are not inside an administrative shell', $PSVersionTable.PSVersion.ToString(2)));
                'AdminMenu'      = $TRUE;
            },
            @{
                'Caption' = 'Logging';
                'Command' = 'Show-IcingaForWindowsMenuManageViewLogs';
                'Help'    = 'View different logs';
            },
            @{
                'Caption' = 'Icinga for Windows Features';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageIcingaForWindowsFeatures';
                'Help'    = 'Allows you to modify certain settings for Icinga for Windows';
            },
            @{
                'Caption' = 'Troubleshooting';
                'Command' = 'Show-IcingaForWindowsMenuManageTroubleshooting';
                'Help'    = 'Resolve problems with your Icinga for Windows environment with pre-defined actions';
            }
            <#,
            @{
                'Caption' = 'Health Check';
                'Command' = '';
                'Help'    = 'Check the current health and status information of your installation';
            }#>
        );
}
