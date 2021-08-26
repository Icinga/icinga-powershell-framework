function Show-IcingaForWindowsManagementConsolePopIcingaRepository()
{
    [array]$Repositories = @();
    [array]$RepoList     = Get-IcingaRepositories;
    [int]$MaxLength      = Get-IcingaMaxTextLength -TextArray $RepoList.Name;

    foreach ($repo in $RepoList) {

        $PrintName = Add-IcingaWhiteSpaceToString -Text $repo.Name -Length $MaxLength;
        $PrintName = [string]::Format('{0}=> {1}', $PrintName, $repo.Value.RemotePath);

        $Repositories += @{
            'Caption' = $PrintName;
            'Command' = 'Show-IcingaForWindowsManagementConsolePopIcingaRepository';
            'Help'    = '';
            'Action'  = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = ([string]::Format('Move Icinga Repository "{0}" to bottom', $repo.Name));
                    '-Command'      = 'Pop-IcingaRepository';
                    '-CmdArguments' = @{
                        '-Name' = $repo.Name;
                    }
                }
            }
        }
    }

    if ($Repositories.Count -ne 0) {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'Select a repository to move it to the bottom of the list' `
            -Entries $Repositories;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no local configured Icinga Repositories'
    }
}
