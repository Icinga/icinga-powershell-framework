function Install-Icinga()
{
    param (
        [string]$InstallCommand  = $null,
        [string]$InstallFile     = '',
        [switch]$NoSSLValidation = $FALSE
    );

    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    # Always ensure we use the proper TLS Version
    Set-IcingaTLSVersion;

    $Global:Icinga.Protected.ServiceRestartLock = $TRUE;

    # Ignore SSL validation in case we set the flag
    if ($NoSSLValidation) {
        Enable-IcingaUntrustedCertificateValidation;
    }

    if ($global:Icinga.ContainsKey('InstallWizard') -eq $FALSE) {
        $global:Icinga.Add(
            'InstallWizard', @{
                'AdminShell'                = (Test-AdministrativeShell);
                'LastInput'                 = '';
                'LastNotice'                = '';
                'LastWarning'               = @();
                'LastError'                 = @();
                'DirectorError'             = '';
                'HeaderPreview'             = '';
                'DirectorSelfServiceConfig' = $null;
                'DirectorSelfService'       = $FALSE;
                'DirectorRegisteredHost'    = $FALSE;
                'DirectorInstallError'      = $FALSE;
                'LastParent'                = [System.Collections.ArrayList]@();
                'LastValues'                = @();
                'DisabledEntries'           = @{ };
                'Config'                    = @{ };
                'ConfigSwap'                = @{ };
                'ParentConfig'              = $null;
                'Menu'                      = 'Install-Icinga';
                'NextCommand'               = '';
                'NextArguments'             = $null;
                'HeaderSelection'           = $null;
                'DisplayAdvanced'           = $FALSE;
                'ShowAdvanced'              = $FALSE;
                'ShowHelp'                  = $FALSE;
                'ShowCommand'               = $FALSE;
                'DeleteValues'              = $FALSE;
                'HeaderPrint'               = $FALSE;
                'JumpToSummary'             = $FALSE;
                'Closing'                   = $FALSE;
            }
        );
    } else {
        $Global:Icinga.InstallWizard.LastWarning.Clear();
        $Global:Icinga.InstallWizard.LastError.Clear();
    }

    if ([string]::IsNullOrEmpty($InstallFile) -eq $FALSE) {
        $InstallCommand = Read-IcingaFileSecure -File $InstallFile -ExitOnReadError;
    }

    # Use our install command to configure everything
    if ([string]::IsNullOrEmpty($InstallCommand) -eq $FALSE) {

        try {
            $JsonInstallCmd = ConvertFrom-Json -InputObject $InstallCommand -ErrorAction Stop;
        } catch {
            Write-IcingaConsoleError 'Failed to deserialize the provided JSON from file or command: {0}' -Objects $_.Exception.Message;
            Clear-IcingaInternalServiceInformation;
            return;
        }

        # Add our "old" swap internally
        $OldConfigSwap  = Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap';
        Disable-IcingaFrameworkConsoleOutput;

        [hashtable]$IcingaConfiguration = Convert-IcingaForwindowsManagementConsoleJSONConfig -Config $JsonInstallCmd;

        # First run our configuration values
        $Success = Invoke-IcingaForWindowsManagementConsoleCustomConfig -IcingaConfiguration $IcingaConfiguration;

        if ($Success -eq $FALSE) {
            Clear-IcingaInternalServiceInformation;
            return;
        }

        # In case we use the director, we require to first fetch all basic values from the Self-Service API then
        # require to register the host to fet the remaining content
        if ($IcingaConfiguration.ContainsKey('IfW-DirectorSelfServiceKey') -And $IcingaConfiguration.ContainsKey('IfW-DirectorUrl')) {
            Enable-IcingaFrameworkConsoleOutput;
            Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate;
            Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate -Register;
            Disable-IcingaFrameworkConsoleOutput;
        } else {
            # Now load all remaining values we haven't set and define the defaults
            Add-IcingaForWindowsInstallationAdvancedEntries;
        }

        # Now apply our configuration again to ensure the defaults are overwritten again
        # Suite a mess, but we can improve this later
        $Success = Invoke-IcingaForWindowsManagementConsoleCustomConfig -IcingaConfiguration $IcingaConfiguration;

        if ($Success -eq $FALSE) {
            Clear-IcingaInternalServiceInformation;
            return;
        }

        Enable-IcingaFrameworkConsoleOutput;

        Start-IcingaForWindowsInstallation -Automated;

        # Set our "old" swap live again. By doing so, we can still continue our old
        # configuration
        Set-IcingaPowerShellConfig -Path 'Framework.Config.Swap' -Value $OldConfigSwap;
        Clear-IcingaInternalServiceInformation;
        return;
    }

    while ($TRUE) {

        # Do nothing else anymore in case we are closing the management console
        if ($global:Icinga.InstallWizard.Closing) {
            break;
        }

        $FrameworkInstalled = Get-IcingaPowerShellConfig -Path 'Framework.Installed';

        if ($null -eq $FrameworkInstalled) {
            $FrameworkInstalled = $FALSE;
        }

        if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.NextCommand) -Or $global:Icinga.InstallWizard.NextCommand -eq 'Install-Icinga') {
            Show-IcingaForWindowsInstallerMenu `
                -Header 'What do you want to do?' `
                -Entries @(
                    @{
                        'Caption' = 'Base Installation';
                        'Command' = 'Show-IcingaForWindowsInstallerMenuInstallWindows';
                        'Help'    = 'Allows you to install Icinga for Windows with all required components and options.'
                    },
                    @{
                        'Caption'   = 'Component Manager';
                        'Command'   = 'Show-IcingaForWindowsManagementConsoleComponentManager';
                        'Help'      = 'Allows you to manage components for Icinga for Windows.';
                        'AdminMenu' = $TRUE;
                    },
                    @{
                        'Caption' = 'Settings';
                        'Command' = 'Show-IcingaForWindowsMenuManage';
                        'Help'    = 'Allows you to modify your current Icinga for Windows installation.';
                    },
                    @{
                        'Caption' = 'Overview';
                        'Command' = 'Show-IcingaForWindowsMenuListEnvironment';
                        'Help'    = 'Shows you an overview of your current Icinga for Windows installation, including installed components and system informations.';
                    },
                    @{
                        'Caption' = 'Icinga Shell';
                        'Command' = 'Invoke-IcingaForWindowsMenuStartIcingaShell';
                        'Help'    = 'Starts an interactive PowerShell with all loaded Icinga for Windows components.';
                    }
                ) `
                -DefaultIndex 0;
        } else {
            $NextArguments = $global:Icinga.InstallWizard.NextArguments;

            if ($global:Icinga.InstallWizard.NextCommand.Contains(':')) {
                $NextArguments = @{
                    'Value' = ($global:Icinga.InstallWizard.NextCommand.Split(':')[1]);
                };
                $global:Icinga.InstallWizard.NextCommand = $global:Icinga.InstallWizard.NextCommand.Split(':')[0];
            }

            try {
                if ($null -ne $NextArguments -And $NextArguments.Count -ne 0) {
                    & $global:Icinga.InstallWizard.NextCommand @NextArguments;
                } else {
                    & $global:Icinga.InstallWizard.NextCommand;
                }
            } catch {
                $ErrMsg = $_.Exception.Message;

                $global:Icinga.InstallWizard.LastError     += [string]::Format('Failed to enter menu "{0}". Error "{1}', $global:Icinga.InstallWizard.NextCommand, $ErrMsg);
                $global:Icinga.InstallWizard.NextCommand   = 'Install-Icinga';
                $global:Icinga.InstallWizard.NextArguments = @{ };
            }
        }
    }

    Clear-IcingaInternalServiceInformation;

    if ($null -ne (Get-Command -Name 'Set-IcingaForWindowsManagementConsoleClosing' -ErrorAction SilentlyContinue)) {
        Set-IcingaForWindowsManagementConsoleClosing -Completed;
    }
}
