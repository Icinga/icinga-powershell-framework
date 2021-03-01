function Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($null -eq $Value -or $Value.Count -eq 0) {
        $LocalApiKey = Get-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey';
        if ([string]::IsNullOrEmpty($LocalApiKey) -eq $FALSE) {
            $Value += $LocalApiKey;
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the Self-Service API key for the Host-Template to use:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This is the Self-Service API for the host template to use. To get this, you will have to set the host template to be an "Icinga 2 Agent" template inside the Icinga Director. Afterwards you see an "Agent" tab on the top right navigation, providing you with the key. In case you entered this menu for the first time and see a key already present, this means the installer already run once and therefor you will be presented with your host key. If a host is already present within the Icinga Director, you can also use the "Agent" tab to get the key of this host directly to enter here';
                'Action'  = @{
                    'Command'   = 'Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate';
                    'Arguments' = @{
                        '-Register' = $FALSE;
                    }
                }
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-DirectorSelfServiceKey' -Value 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';
