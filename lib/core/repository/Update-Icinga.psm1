function Update-Icinga()
{
    param (
        [string]$Name     = $null,
        [string]$Version  = 'release',
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE,
        [switch]$Confirm  = $FALSE,
        [switch]$Force    = $FALSE
    );

    if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
        $Release = $TRUE;
    }

    $CurrentInstallation   = Get-IcingaInstallation -Release:$Release -Snapshot:$Snapshot;
    [bool]$UpdateJEA       = $FALSE;
    [array]$ComponentsList = @();
    [bool]$IsInstalled     = $FALSE;

    # We need to make sure that the framework is always installed first as component
    # to prevent possible race-conditions during update, in case we update plugins
    # before the framework. For plugins this applies as well, as other components
    # could use them as depdency
    if ($CurrentInstallation.ContainsKey('framework')) {
        $ComponentsList += 'framework';
    }
    if ($CurrentInstallation.ContainsKey('plugins')) {
        $ComponentsList += 'plugins';
    }

    # Add all other components, but skip the framework in this case
    foreach ($entry in $CurrentInstallation.Keys) {
        if ($entry -eq 'framework' -Or $entry -eq 'plugins') {
            continue;
        }
        $ComponentsList += $entry;
    }

    # Now process with your installation
    foreach ($entry in $ComponentsList) {
        $Component = $CurrentInstallation[$entry];

        if ([string]::IsNullOrEmpty($Name) -eq $FALSE -And $Name -ne $entry) {
            continue;
        }

        $IsInstalled = $TRUE;

        $NewVersion = $Component.LatestVersion;

        if ([string]::IsNullOrEmpty($Version) -eq $FALSE) {
            # Ensure we are backwards compatible with Icinga for Windows v1.11.0 which broke the version update feature
            if ($Version.ToLower() -ne 'release' -And $Version.ToLower() -ne 'latest') {
                $NewVersion = $Version;
            }
        }

        if ([string]::IsNullOrEmpty($NewVersion)) {
            Write-IcingaConsoleNotice 'No update package found for component "{0}"' -Objects $entry;
            continue;
        }

        $LockedVersion = Get-IcingaComponentLock -Name $entry;

        if ($null -ne $LockedVersion) {
            $NewVersion = $LockedVersion;
        }

        if ([Version]$NewVersion -le [Version]$Component.CurrentVersion -And $Force -eq $FALSE) {
            Write-IcingaConsoleNotice 'The installed version "{0}" of component "{1}" is identical or lower than the new version "{2}". Use "-Force" to install anyway' -Objects $Component.CurrentVersion, $entry, $NewVersion;
            continue;
        }

        if ($entry.ToLower() -ne 'agent' -And $entry.ToLower() -ne 'service') {
            $UpdateJEA = $TRUE;
        }

        Install-IcingaComponent -Name $entry -Version $NewVersion -Release:$Release -Snapshot:$Snapshot -Confirm:$Confirm -Force:$Force -KeepRepoErrors;
    }

    if ($IsInstalled -eq $FALSE) {
        Write-IcingaConsoleError 'Failed to update the component "{0}", as it is not installed' -Objects $Name;
    }

    # Update JEA profile if JEA is enabled once the update is complete
    if ([string]::IsNullOrEmpty((Get-IcingaJEAContext)) -eq $FALSE -And $UpdateJEA) {
        Update-IcingaJEAProfile;
        Restart-IcingaForWindows;
    }
}
