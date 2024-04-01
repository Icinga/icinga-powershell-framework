function Test-IcingaRepositoryErrorState()
{
    param (
        [string]$Repository
    );

    if ([string]::IsNullOrEmpty($Repository)) {
        return $FALSE;
    }

    if ($Global:Icinga -eq $null) {
        return $FALSE;
    }

    if ($Global:Icinga.Contains('Private') -eq $FALSE) {
        return $FALSE;
    }

    if ($Global:Icinga.Private.Contains('RepositoryStatus') -eq $FALSE) {
        return $FALSE;
    }

    if ($Global:Icinga.Private.RepositoryStatus.Contains('FailedRepositories') -eq $FALSE) {
        return $FALSE;
    }

    if ($Global:Icinga.Private.RepositoryStatus.FailedRepositories.ContainsKey($Repository) -eq $FALSE) {
        return $FALSE;
    }

    return $TRUE;
}
