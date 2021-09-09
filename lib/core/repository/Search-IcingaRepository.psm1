function Search-IcingaRepository()
{
    param (
        [string]$Name     = $null,
        [string]$Version  = $null,
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE
    );

    if ($Version -eq 'release') {
        $Version = $null;
    }

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a component name';
        return;
    }

    if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
        $Release = $TRUE;
    }

    $Repositories           = Get-IcingaRepositories -ExcludeDisabled;
    [Version]$LatestVersion = $null;
    [string]$SourcePath     = $null;
    [bool]$FoundPackage     = $FALSE;
    [array]$Output          = @();
    [bool]$FoundPackage     = $FALSE;

    $SearchList             = New-Object -TypeName PSObject;
    $SearchList | Add-Member -MemberType NoteProperty -Name 'Repos' -Value @();

    foreach ($entry in $Repositories) {
        $RepoContent = Read-IcingaRepositoryFile -Name $entry.Name;

        if ($null -eq $RepoContent) {
            continue;
        }

        if ((Test-IcingaPowerShellConfigItem -ConfigObject $RepoContent -ConfigKey 'Packages') -eq $FALSE) {
            continue;
        }

        foreach ($repoEntry in $RepoContent.Packages.PSObject.Properties.Name) {

            if ($repoEntry -NotLike $Name -Or $Name.ToLower() -eq 'kickstart') {
                continue;
            }

            $RepoData = New-Object -TypeName PSObject;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'Name'          -Value $entry.Name;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'RemoteSource'  -Value $RepoContent.Info.RemoteSource;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'ComponentName' -Value $repoEntry;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'Packages'      -Value @();

            foreach ($package in $RepoContent.Packages.$repoEntry) {

                $ComponentData = New-Object -TypeName PSObject;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Version'  -Value $package.Version;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Location' -Value $package.Location;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Snapshot' -Value $package.Snapshot;

                if ($Snapshot -And $package.Snapshot -eq $TRUE -And [string]::IsNullOrEmpty($Version)) {
                    $RepoData.Packages += $ComponentData;
                    continue;
                }

                if ($Snapshot -And $package.Snapshot -eq $TRUE -And [string]::IsNullOrEmpty($Version) -eq $FALSE -And [version]$package.Version -eq [version]$Version) {
                    $RepoData.Packages += $ComponentData;
                    continue;
                }

                if ($Release -And [string]::IsNullOrEmpty($Version) -And $package.Snapshot -eq $FALSE) {
                    $RepoData.Packages += $ComponentData;
                    continue;
                }

                if ([string]::IsNullOrEmpty($Version) -eq $FALSE -And $Release -eq $FALSE -And $Snapshot -eq $FALSE -And $package.Snapshot -eq $FALSE) {
                    $RepoData.Packages += $ComponentData;
                    continue;
                }
            }

            if ($RepoData.Packages.Count -ne 0) {
                $FoundPackage = $TRUE;
            }

            $SearchList.Repos += $RepoData;
        }
    }

    if ($FoundPackage -eq $FALSE) {
        $SearchVersion = 'release';
        if ([string]::IsNullOrEmpty($Version) -eq $FALSE) {
            $SearchVersion = $Version;
        }
        if ($Release) {
            Write-IcingaConsoleNotice 'The component "{0}" was not found on stable channel with version "{1}"' -Objects $Name, $SearchVersion;
        }
        if ($Snapshot) {
            Write-IcingaConsoleNotice 'The component "{0}" was not found on snapshot channel with version "{1}"' -Objects $Name, $SearchVersion;
        }
        return;
    }

    foreach ($repo in $SearchList.Repos) {
        if ($repo.Packages.Count -eq 0) {
            continue;
        }

        $Output += $repo.Name;
        $Output += '-----------';
        $Output += [string]::Format('Source => {0}', $repo.RemoteSource);
        $Output += '';
        $Output += $repo.ComponentName;

        [array]$VersionList = $repo.Packages | Sort-Object { $_.Version } -Descending;

        foreach ($componentData in $VersionList) {
            $Output += [string]::Format('{0} => {1}', $componentData.Version, $componentData.Location);
        }
        $Output += '';
    }

    Write-Host ($Output | Out-String);
}
