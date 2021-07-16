function Get-IcingaRepositories()
{
    param (
        [switch]$ExcludeDisabled = $FALSE
    );

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';
    [array]$RepoList     = $CurrentRepositories.PSObject.Properties | Sort-Object { $_.Value.Order } -Descending;

    if ($ExcludeDisabled -eq $FALSE) {
        return $RepoList;
    }

    [array]$ActiveRepos = @();

    foreach ($repo in $RepoList) {
        if ($repo.Value.Enabled -eq $FALSE) {
            continue;
        }

        $ActiveRepos += $repo;
    }

    return $ActiveRepos;
}
