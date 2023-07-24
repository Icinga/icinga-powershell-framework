function Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceConfig()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    # Ensure we simply set the global variable for the Config in case we run in automation mode
    if ($Automated) {
        if ($null -ne $Value -And $null -ne $Value[0]) {
            $Global:Icinga.InstallWizard.DirectorSelfServiceConfig = ConvertFrom-Json -InputObject $Value[0] -ErrorAction Stop;
            return;
        }
    }

    # Set the default if no value ist set
    if ($Value -IsNot [array] -Or $null -eq $Value -or $Value.Count -eq 0) {
        $Value.Clear();
        if ($null -eq $Global:Icinga.InstallWizard.DirectorSelfServiceConfig) {
            $Value += '{ "address": "$ifw.hostaddress$" }';
        } else {
            $Value += ConvertTo-Json -InputObject $Global:Icinga.InstallWizard.DirectorSelfServiceConfig -Depth 100 -Compress;
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'You can update the Icinga Director Self-Service config in this section. USE WITH CARE!' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This is the configuration JSON-Object for the Icinga Director Self-Service API. You can set a custom IP-Address or define the display name of an object with "display_name" as key. Use this methid with caution! Not all configuration elements in general possible are accessible by using the Self-Service keys.';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # Fetch the current JSON-String inserted by the user
    [string]$ConfigString = Get-IcingaForWindowsInstallerValuesFromStep;

    if ([string]::IsNullOrEmpty($ConfigString) -eq $FALSE) {
        try {
            # Validate that our JSON is correct
            $Global:Icinga.InstallWizard.DirectorSelfServiceConfig = ConvertFrom-Json -InputObject $ConfigString -ErrorAction Stop;
        } catch {
            # Set some defaults to ensure we don't break the installer
            Write-IcingaConsoleError ([string]::Format('The provided Icinga Director Self Service configuration "{0}" does not appear to be a valid JSON-String. E.g.: {{ "address": "$ifw.hostaddress$" }} without leading and ending "" before and after {{ }}', $ConfigString));
            $Global:Icinga.InstallWizard.DirectorSelfServiceConfig = $null;
            Set-IcingaForWindowsInstallerValuesFromStep -Values @( '{ }' );
        }
    } else {
        $Global:Icinga.InstallWizard.DirectorSelfServiceConfig = $null;
    }
}

Set-Alias -Name 'IfW-DirectorSelfServiceConfig' -Value 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceConfig';
