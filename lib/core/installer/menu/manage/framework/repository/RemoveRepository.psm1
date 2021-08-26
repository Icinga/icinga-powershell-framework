function Show-IcingaForWindowsManagementConsoleRemoveIcingaRepository()
{
    [array]$Repositories = @();
    [array]$RepoList     = Get-IcingaRepositories;
    [int]$MaxLength      = Get-IcingaMaxTextLength -TextArray $RepoList.Name;

    foreach ($repo in $RepoList) {

        $PrintName = Add-IcingaWhiteSpaceToString -Text $repo.Name -Length $MaxLength;
        $PrintName = [string]::Format('{0}=> {1}', $PrintName, $repo.Value.RemotePath);

        $Repositories += @{
            'Caption' = $PrintName;
            'Command' = 'Show-IcingaForWindowsManagementConsoleRemoveIcingaRepository';
            'Help'    = '';
            'Action'  = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = ([string]::Format('Remove Icinga Repository "{0}"', $repo.Name));
                    '-Command'      = 'Remove-IcingaRepository';
                    '-CmdArguments' = @{
                        '-Name' = $repo.Name;
                    }
                }
            }
        }
    }

    if ($Repositories.Count -ne 0) {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'Select a repository to remove it from the system' `
            -Entries $Repositories;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no local configured Icinga Repositories'
    }
}
