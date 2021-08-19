function Show-IcingaForWindowsManagementConsoleSetIcingaStableRepositories()
{
    param (
        [array]$Value          = @( 'https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $CurrentRepositories = Get-IcingaRepositories;

    foreach ($entry in $CurrentRepositories) {
        if ($entry.Name -eq 'Icinga Stable') {
            $Value = $entry.Value.RemotePath;
            break;
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the URL/Path for the location of your "Icinga Stable" Repository:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageIcingaRepositories';
                'Help'    = 'Sets the current repository for Icinga for Windows as "Icinga Stable"';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -ContinueFirstValue `
        -MandatoryValue `
        -ConfigElement `
        -HiddenConfigElement `
        -Advanced `
        -NoConfigSwap;

    if (Test-IcingaForWindowsManagementConsoleContinue) {
        $UserInput = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsManagementConsoleSetIcingaStableRepositories';

        Add-IcingaRepository -Name 'Icinga Stable' -RemotePath $UserInput -Force;

        $global:Icinga.InstallWizard.LastNotice = ([string]::Format('Updated repository "Icinga Stable" with URL "{0}"', $UserInput));
    }
}
