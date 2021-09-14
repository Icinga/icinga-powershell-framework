function Push-IcingaRepository()
{
    param (
        [string]$Name   = $null,
        [switch]$Silent = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        if ($Silent -eq $FALSE) {
            Write-IcingaConsoleError 'You have to provide a name for the repository';
        }
        return;
    }

    $Name = $Name.Replace('.', '-');

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        if ($Silent -eq $FALSE) {
            Write-IcingaConsoleNotice 'You have no repositories configured yet.';
        }
        return;
    }

    [array]$RepoList = Get-IcingaRepositories;
    [int]$Index      = 0;

    foreach ($repo in $RepoList) {
        if ($repo.Name -eq $Name) {
            continue;
        }

        $CurrentRepositories.($repo.Name).Order = [int]$Index;
        $Index += 1;
    }

    $CurrentRepositories.$Name.Order = [int]$Index;

    if ($Silent -eq $FALSE) {
        Write-IcingaConsoleNotice 'The repository "{0}" was put at the top of the repository list' -Objects $Name;
    }

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
}
