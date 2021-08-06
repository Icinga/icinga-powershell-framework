function Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser()
{
    param (
        [array]$Value          = @( 'NT Authority\NetworkService' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please define the user the Icinga Agent service should run with:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';
                'Help'    = 'Allows you to override the default user the Icinga Agent is running with as service. In case a password is required, you can add it in the next step';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # Remove a defined password in case we are running system services
    [string]$ServiceUser = Get-IcingaForWindowsInstallerValuesFromStep;

    if ([string]::IsNullOrEmpty($ServiceUser) -eq $FALSE) {
        $ServiceUser = $ServiceUser.ToLower();
    } else {
        $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser';
        return;
    }

    if ($ServiceUser -eq 'networkservice' -Or $ServiceUser -eq 'nt authority\networkservice' -Or $ServiceUser -eq 'localsystem' -Or $ServiceUser -eq 'nt authority\localservice' -Or $ServiceUser -eq 'localservice') {
        Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';
        $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallerConfigurationSummary';
        $global:Icinga.InstallWizard.NextArguments = @{ };
    } else {
        $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';
    }
}

Set-Alias -Name 'IfW-AgentUser' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser';
