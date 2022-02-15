function Show-IcingaForWindowsInstallerMenuSelectCertificate()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'How do you want to create the Icinga certificate?' `
        -Entries @(
            @{
                'Caption' = 'Sign certificate manually on the Icinga CA master';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This option will not require you to provide additional details for certificate generation and only require a connection to/from this host. You will have to sign the certificate manually on the Icinga CA master with "icinga2 ca sign <request>"';
            },
            @{
                'Caption' = 'Sign certificate with a ticket';
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
                'Help'    = 'By selecting this option, this host will connect to a parent Icinga node and sign the certificate with a ticket you have to provide in the next step';
            },
            @{
                'Caption' = 'Sign certificate with local ca.crt';
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';
                'Help'    = 'This will allow you to sign the certificate for this host directly on this machine. For this you will have to store your Icinga ca.crt somewhere accessible to this system. In the next step you are asked to provide the path to the location of your ca.crt';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # Make sure we delete configuration no longer required
    switch (Get-IcingaForWindowsManagementConsoleLastInput) {
        '0' {
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';
            break;
        };
        '1' {
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';
            break;
        };
        '2' {
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
            break;
        };
    }

    # By Default, we are not jumping to the Summary on this menu but will require this in case
    # we choose CAFile selection and are on the summary page, as then we do not want to be prompted
    # for the Hostname again and require to tell the CA menu, that we should directly move to the
    # summary page again
    $LastInput = Get-IcingaForWindowsManagementConsoleLastInput;

    if ($LastInput -eq '2' -And $JumpToSummary) {
        $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';
        $global:Icinga.InstallWizard.NextArguments = @{ 'JumpToSummary' = $TRUE; };
    }
}

Set-Alias -Name 'IfW-Certificate' -Value 'Show-IcingaForWindowsInstallerMenuSelectCertificate';
