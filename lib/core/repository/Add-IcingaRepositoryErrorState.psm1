function Add-IcingaRepositoryErrorState()
{
    param (
        [string]$Repository = $null
    );

    if ([string]::IsNullOrEmpty($Repository)) {
        return;
    }

    if ($Global:Icinga -eq $null) {
        return;
    }

    if ($Global:Icinga.Contains('Private') -eq $FALSE) {
        return;
    }

    if ($Global:Icinga.Private.Contains('RepositoryStatus') -eq $FALSE) {
        return;
    }

    if ($Global:Icinga.Private.RepositoryStatus.Contains('FailedRepositories') -eq $FALSE) {
        return;
    }

    if ($Global:Icinga.Private.RepositoryStatus.FailedRepositories.ContainsKey($Repository)) {
        return;
    }

    $Global:Icinga.Private.RepositoryStatus.FailedRepositories.Add($Repository, $TRUE);
}
