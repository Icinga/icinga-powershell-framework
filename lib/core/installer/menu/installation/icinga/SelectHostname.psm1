function Show-IcingaForWindowsInstallerMenuSelectHostname()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '1',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'How is your host object named in Icinga?' `
        -Entries @(
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (current)', (Get-IcingaHostname -AutoUseFQDN 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and not modify the name at all';
            },
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (lowercase)', (Get-IcingaHostname -AutoUseFQDN 1 -LowerCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and modify all characters to lowercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (uppercase)', (Get-IcingaHostname -AutoUseFQDN 1 -UpperCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and modify all characters to uppercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (current)', (Get-IcingaHostname -AutoUseHostname 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension without modification';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (lowercase)', (Get-IcingaHostname -AutoUseHostname 1 -LowerCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension and modify all characters to lowercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (uppercase)', (Get-IcingaHostname -AutoUseHostname 1 -UpperCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension and modify all characters to uppercase';
            },
            @{
                'Caption' = 'Set custom Hostname';
                'Command' = 'Show-IcingaForWindowsInstallationMenuEnterCustomHostname';
                'Help'    = 'Allows you to set a custom hostname';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    $LastInput = Get-IcingaForWindowsManagementConsoleLastInput;

    if ([string]::IsNullOrEmpty($LastInput) -eq $FALSE -and $LastInput -ne '6') {
        # Remove the set hostname in case we choose a different option
        Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallationMenuEnterCustomHostname';
    } elseif ($LastInput -eq '6' -And $JumpToSummary) {
        $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallationMenuEnterCustomHostname';
        $global:Icinga.InstallWizard.NextArguments = @{ 'JumpToSummary' = $TRUE; };
    }
}

Set-Alias -Name 'IfW-Hostname' -Value 'Show-IcingaForWindowsInstallerMenuSelectHostname';
