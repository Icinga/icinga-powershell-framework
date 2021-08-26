function Show-IcingaForWindowsManagementConsoleIcingaRepositoriesList()
{
    [array]$Repositories = @();
    [array]$RepoList     = Get-IcingaRepositories;
    [int]$MaxLength      = Get-IcingaMaxTextLength -TextArray $RepoList.Name;

    foreach ($repo in $RepoList) {

        $PrintName = Add-IcingaWhiteSpaceToString -Text $repo.Name -Length $MaxLength;
        $PrintName = [string]::Format('{0}=> {1}', $PrintName, $repo.Value.RemotePath);

        $Repositories += @{
            'Caption'  = $PrintName;
            'Command'  = 'Show-IcingaForWindowsManagementConsoleIcingaRepositoriesList';
            'Help'     = '';
            'Disabled' = (-Not $repo.Value.Enabled);
        }
    }

    if ($Repositories.Count -ne 0) {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'List of local configured Icinga Repositories' `
            -Entries $Repositories;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no local configured Icinga Repositories'
    }
}
