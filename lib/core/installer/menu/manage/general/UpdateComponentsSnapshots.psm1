function Show-IcingaForWindowsMenuUpdateComponentsSnapshot()
{
    $IcingaInstallation      = Get-IcingaInstallation -Snapshot;
    [int]$MaxComponentLength = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Keys;
    [array]$UpdateList       = @();

    foreach ($entry in $IcingaInstallation.Keys) {
        $Component = $IcingaInstallation[$entry];

        $LatestVersion = $Component.LatestVersion;
        if ([string]::IsNullOrEmpty($Component.LockedVersion) -eq $FALSE) {
            if ([Version]$Component.CurrentVersion -ge [Version]$Component.LockedVersion) {
                continue;
            }
            $LatestVersion = [string]::Format('{0}*', $Component.LockedVersion);
        }

        if ([string]::IsNullOrEmpty($LatestVersion)) {
            continue;
        }

        $UpdateList += @{
            'Caption'  = ([string]::Format('{0} [{1}] => [snapshot]', (Add-IcingaWhiteSpaceToString -Text $entry -Length $MaxComponentLength), $Component.CurrentVersion));
            'Command'  = 'Show-IcingaForWindowsMenuUpdateComponents';
            'Help'     = ([string]::Format('This will update "{0}" from current version "{1}" to latest snapshot version', $entry, $Component.CurrentVersion));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = ([string]::Format('Update "{0}" from version "{1}" to latest snapshot version', $entry, $Component.CurrentVersion));
                    '-Command'      = 'Update-Icinga';
                    '-CmdArguments' = @{
                        '-Name'     = $entry;
                        '-Snapshot' = $TRUE;
                        '-Confirm'  = $TRUE;
                        '-Force'    = $TRUE;
                    }
                }
            }
        }
    }

    if ($UpdateList.Count -ne 0) {
        $UpdateList += @{
            'Caption'  = 'Update entire environment';
            'Command'  = 'Show-IcingaForWindowsMenuUpdateComponents';
            'Help'     = 'This will update all components listed above to the mentioned snapshot version'
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = 'Update entire Icinga for Windows environment';
                    '-Command'      = 'Update-Icinga';
                    '-CmdArguments' = @{
                        '-Snapshot' = $TRUE;
                        '-Confirm'  = $TRUE;
                        '-Force'    = $TRUE;
                    }
                }
            }
        }

        Show-IcingaForWindowsInstallerMenu `
            -Header 'Updates Icinga for Windows components. Select an entry to continue:' `
            -Entries $UpdateList;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no updates pending for your environment'
    }
}
