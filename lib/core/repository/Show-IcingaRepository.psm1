function Show-IcingaRepository()
{
    [hashtable]$Repositories = @{ };
    [array]$RepoSummary      = @(
        'List of configured repositories on this system. The list order matches the apply order.',
        ''
    );
    [array]$RepoList = Get-IcingaRepositories;

    foreach ($repo in $RepoList) {

        $RepoSummary += $repo.Name;
        $RepoSummary += '-----------';

        [int]$MaxLength  = Get-IcingaMaxTextLength -TextArray $repo.Value.PSObject.Properties.Name;
        [array]$RepoData = @();

        foreach ($repoConfig in $repo.Value.PSObject.Properties) {
            $PrintName = Add-IcingaWhiteSpaceToString -Text $repoConfig.Name -Length $MaxLength;
            $RepoData += [string]::Format('{0} => {1}', $PrintName, $repoConfig.Value);
        }

        $RepoSummary += $RepoData | Sort-Object;
        $RepoSummary += '';
    }

    if ($RepoList.Count -eq 0) {
        $RepoSummary += 'No repositories configured';
    }

    Write-Output $RepoSummary;
}
