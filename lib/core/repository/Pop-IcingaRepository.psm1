function Pop-IcingaRepository()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    $Name = $Name.Replace('.', '-');

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        Write-IcingaConsoleNotice 'You have no repositories configured yet.';
        return;
    }

    [array]$RepoList = Get-IcingaRepositories;
    [int]$Index      = $RepoList.Count - 1;

    foreach ($repo in $RepoList) {
        if ($repo.Name -eq $Name) {
            continue;
        }

        $CurrentRepositories.($repo.Name).Order = [int]$Index;
        $Index -= 1;
    }

    $CurrentRepositories.$Name.Order = [int]$Index;

    Write-IcingaConsoleNotice 'The repository "{0}" was put at the bottom of the repository list' -Objects $Name;

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
}
