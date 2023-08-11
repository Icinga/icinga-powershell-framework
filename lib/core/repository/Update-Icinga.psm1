function Update-Icinga()
{
    param (
        [string]$Name     = $null,
        [string]$Version  = $null,
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE,
        [switch]$Confirm  = $FALSE,
        [switch]$Force    = $FALSE
    );

    if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
        $Release = $TRUE;
    }

    $CurrentInstallation = Get-IcingaInstallation -Release:$Release -Snapshot:$Snapshot;

    foreach ($entry in $CurrentInstallation.Keys) {
        $Component = $CurrentInstallation[$entry];

        if ([string]::IsNullOrEmpty($Name) -eq $FALSE -And $Name -ne $entry) {
            continue;
        }

        $NewVersion = $Component.LatestVersion;

        if ([string]::IsNullOrEmpty($Version) -eq $FALSE) {
            $NewVersion = $Version;
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

        Install-IcingaComponent -Name $entry -Version $NewVersion -Release:$Release -Snapshot:$Snapshot -Confirm:$Confirm -Force:$Force;
    }

    # Update JEA profile if JEA is enabled once the update is complete
    if ([string]::IsNullOrEmpty((Get-IcingaJEAContext)) -eq $FALSE) {
        Update-IcingaJEAProfile;
        Restart-IcingaWindowsService;
    }
}
