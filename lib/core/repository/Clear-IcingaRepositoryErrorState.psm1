function Clear-IcingaRepositoryErrorState()
{
    if ($Global:Icinga -eq $null) {
        return;
    }

    if ($Global:Icinga.Contains('Private') -eq $FALSE) {
        return;
    }

    if ($Global:Icinga.Private.Contains('RepositoryStatus') -eq $FALSE) {
        return;
    }

    $Global:Icinga.Private.RepositoryStatus.FailedRepositories = @{ };
}
