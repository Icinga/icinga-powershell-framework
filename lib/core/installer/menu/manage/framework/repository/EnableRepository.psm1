function Show-IcingaForWindowsManagementConsoleEnableIcingaRepository()
{
    [array]$Repositories = @();
    [array]$RepoList     = Get-IcingaRepositories;
    [int]$MaxLength      = Get-IcingaMaxTextLength -TextArray $RepoList.Name;

    foreach ($repo in $RepoList) {

        if ($repo.Value.Enabled) {
            continue;
        }

        $PrintName = Add-IcingaWhiteSpaceToString -Text $repo.Name -Length $MaxLength;
        $PrintName = [string]::Format('{0}=> {1}', $PrintName, $repo.Value.RemotePath);

        $Repositories += @{
            'Caption' = $PrintName;
            'Command' = 'Show-IcingaForWindowsManagementConsoleEnableIcingaRepository';
            'Help'    = '';
            'Action'  = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = ([string]::Format('Enable Icinga Repository "{0}"', $repo.Name));
                    '-Command'      = 'Enable-IcingaRepository';
                    '-CmdArguments' = @{
                        '-Name' = $repo.Name;
                    }
                }
            }
        }
    }

    if ($Repositories.Count -ne 0) {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'Select a repository to enable it from the system' `
            -Entries $Repositories;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no local configured Icinga Repositories'
    }
}
