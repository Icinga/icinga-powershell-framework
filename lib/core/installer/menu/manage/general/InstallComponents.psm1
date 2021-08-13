function Show-IcingaForWindowsMenuInstallComponents()
{
    $IcingaInstallation      = Get-IcingaComponentList;
    $CurrentComponents       = Get-IcingaInstallation -Release;
    [int]$MaxComponentLength = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Components.Keys;
    [array]$InstallList      = @();

    foreach ($entry in $IcingaInstallation.Components.Keys) {
        $LatestVersion = $IcingaInstallation.Components[$entry];
        $LockedVersion = Get-IcingaComponentLock -Name $entry;
        $VersionText   = $LatestVersion;

        # Only show not installed components
        if ($CurrentComponents.ContainsKey($entry)) {
            continue;
        }

        if ($null -ne $LockedVersion) {
            $VersionText   = [string]::Format('{0}*', $LockedVersion);
            $LatestVersion = $LockedVersion;
        }

        $InstallList += @{
            'Caption'  = ([string]::Format('{0} [{1}]', (Add-IcingaWhiteSpaceToString -Text $entry -Length $MaxComponentLength), $VersionText));
            'Command'  = 'Show-IcingaForWindowsMenuInstallComponents';
            'Help'     = ([string]::Format('This will install the component "{0}" with version "{1}"', $entry, $VersionText));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = ([string]::Format('Install component "{0}" with version "{1}"', $entry, $VersionText));
                    '-Command'      = 'Install-IcingaComponent';
                    '-CmdArguments' = @{
                        '-Name'    = $entry;
                        '-Version' = $LatestVersion;
                        '-Release' = $TRUE;
                        '-Confirm' = $TRUE;
                    }
                }
            }
        }
    }

    if ($InstallList.Count -ne 0) {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'Install Icinga for Windows components. Select an entry to continue:' `
            -Entries $InstallList;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no packages found for installation'
    }
}
