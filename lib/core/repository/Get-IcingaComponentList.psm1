function Get-IcingaComponentList()
{
    param (
        [switch]$Snapshot = $FALSE
    );

    $Repositories           = Get-IcingaRepositories -ExcludeDisabled;
    [Version]$LatestVersion = $null;
    [string]$SourcePath     = $null;
    [bool]$FoundPackage     = $FALSE;
    [array]$Output          = @();
    [bool]$FoundPackage     = $FALSE;

    $SearchList             = New-Object -TypeName PSObject;
    $SearchList | Add-Member -MemberType NoteProperty -Name 'Repos'      -Value @();
    $SearchList | Add-Member -MemberType NoteProperty -Name 'Components' -Value @{ };

    foreach ($entry in $Repositories) {
        $RepoContent = Read-IcingaRepositoryFile -Name $entry.Name;

        if ($null -eq $RepoContent) {
            continue;
        }

        if ((Test-IcingaPowerShellConfigItem -ConfigObject $RepoContent -ConfigKey 'Packages') -eq $FALSE) {
            continue;
        }

        foreach ($repoEntry in $RepoContent.Packages.PSObject.Properties.Name) {

            if ($repoEntry.ToLower() -eq 'kickstart') {
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

                if ($package.Snapshot -And $Snapshot -eq $FALSE) {
                    continue;
                }

                if ($package.Snapshot -eq $FALSE -And $Snapshot) {
                    continue;
                }

                if ($Snapshot -eq $FALSE -And (Test-Numeric $package.Version.Replace('.', '')) -eq $FALSE) {
                    continue;
                }

                if ($SearchList.Components.ContainsKey($repoEntry) -eq $FALSE) {
                    $SearchList.Components.Add($repoEntry, $package.Version);
                }

                if ((Test-Numeric $package.Version.Replace('.', '')) -And [version]($SearchList.Components[$repoEntry]) -lt [version]$package.Version) {
                    $SearchList.Components[$repoEntry] = $package.Version;
                }

                $RepoData.Packages += $ComponentData;
            }

            $SearchList.Repos += $RepoData;
        }
    }

    return $SearchList;
}
