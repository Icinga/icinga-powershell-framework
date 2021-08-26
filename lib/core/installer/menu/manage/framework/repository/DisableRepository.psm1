function Show-IcingaForWindowsManagementConsoleDisableIcingaRepository()
{
    [array]$Repositories = @();
    [array]$RepoList     = Get-IcingaRepositories -ExcludeDisabled;
    [int]$MaxLength      = Get-IcingaMaxTextLength -TextArray $RepoList.Name;

    foreach ($repo in $RepoList) {

        $PrintName = Add-IcingaWhiteSpaceToString -Text $repo.Name -Length $MaxLength;
        $PrintName = [string]::Format('{0}=> {1}', $PrintName, $repo.Value.RemotePath);

        $Repositories += @{
            'Caption' = $PrintName;
            'Command' = 'Show-IcingaForWindowsManagementConsoleDisableIcingaRepository';
            'Help'    = '';
            'Action'  = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = ([string]::Format('Disable Icinga Repository "{0}"', $repo.Name));
                    '-Command'      = 'Disable-IcingaRepository';
                    '-CmdArguments' = @{
                        '-Name' = $repo.Name;
                    }
                }
            }
        }
    }

    if ($Repositories.Count -ne 0) {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'Select a repository to disable it from the system' `
            -Entries $Repositories;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no local configured Icinga Repositories'
    }
}
