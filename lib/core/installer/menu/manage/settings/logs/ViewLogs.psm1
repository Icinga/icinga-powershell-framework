function Show-IcingaForWindowsMenuManageViewLogs()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'View all related logs:' `
        -Entries @(
            @{
                'Caption'        = 'View Icinga Agent Main Log';
                'Command'        = 'Show-IcingaForWindowsMenuManageViewLogs';
                'Help'           = 'Allows to view the Icinga Agent main log in case the "mainlog" feature of the Icinga Agent is enabled';
                'Disabled'       = ((-Not (Test-IcingaAgentFeatureEnabled -Feature 'mainlog') -And -Not (Test-IcingaAgentFeatureEnabled -Feature 'windowseventlog')));
                'DisabledReason' = 'It seems like neither the "mainlog" nor the "windowseventlog" feature of the Icinga Agent is enabled';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command'   = 'Start-Process';
                    'Arguments' = @{ '-FilePath' = 'powershell.exe'; '-ArgumentList' = "-NoProfile -Command  `"&{ icinga { Read-IcingaAgentLogFile; }; }`"" };
                }
            },
            @{
                'Caption'        = 'View Icinga Agent Debug Log';
                'Command'        = 'Show-IcingaForWindowsMenuManageViewLogs';
                'Help'           = 'Allows to read the Icinga Agent debug log in case the "debuglog" feature of the Icinga Agent is enabled';
                'Disabled'       = (-Not (Test-IcingaAgentFeatureEnabled -Feature 'debuglog'));
                'DisabledReason' = 'The "debuglog" feature of the Icinga Agent is not enabled';
                'AdminMenu'      = $TRUE;
                'Action'         = @{
                    'Command'   = 'Start-Process';
                    'Arguments' = @{ '-FilePath' = 'powershell.exe'; '-ArgumentList' = "-NoProfile -Command  `"&{ icinga { Read-IcingaAgentDebugLogFile; }; }`"" };
                }
            },
            @{
                'Caption'   = 'View Icinga for Windows EventLog';
                'Command'   = 'Show-IcingaForWindowsMenuManageViewLogs';
                'Help'      = 'Allows to read the Icinga for Windows from the EventLog';
                'AdminMenu' = $TRUE;
                'Action'    = @{
                    'Command'   = 'Start-Process';
                    'Arguments' = @{ '-FilePath' = 'powershell.exe'; '-ArgumentList' = "-NoProfile -Command  `"&{ icinga { Read-IcingaForWindowsLog; }; }`"" };
                }
            },
            @{
                'Caption'   = 'View Icinga for Windows Debug EventLog';
                'Command'   = 'Show-IcingaForWindowsMenuManageViewLogs';
                'Help'      = 'Allows to read the Icinga for Windows  EventLog, filtered by debug messages';
                'AdminMenu' = $TRUE;
                'Action'    = @{
                    'Command'   = 'Start-Process';
                    'Arguments' = @{ '-FilePath' = 'powershell.exe'; '-ArgumentList' = "-NoProfile -Command  `"&{ icinga { Read-IcingaWindowsEventLog -LogName 'Icinga for Windows' -Source 'IfW::Debug'; }; }`"" };
                }
            }
        );
}
