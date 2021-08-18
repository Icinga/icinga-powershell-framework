function Install-Icinga()
{
    param (
        [string]$InstallCommand = $null,
        [string]$InstallFile    = ''
    );

    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    if ($global:Icinga.ContainsKey('InstallWizard') -eq $FALSE) {
        $global:Icinga.Add(
            'InstallWizard', @{
                'AdminShell'      = (Test-AdministrativeShell);
                'LastInput'       = '';
                'LastNotice'      = '';
                'LastError'       = '';
                'HeaderPreview'   = '';
                'LastParent'      = [System.Collections.ArrayList]@();
                'LastValues'      = @();
                'Config'          = @{ };
                'ConfigSwap'      = @{ };
                'ParentConfig'    = $null;
                'Menu'            = 'Install-Icinga';
                'NextCommand'     = '';
                'NextArguments'   = $null;
                'HeaderSelection' = $null;
                'DisplayAdvanced' = $FALSE;
                'ShowAdvanced'    = $FALSE;
                'ShowHelp'        = $FALSE;
                'DeleteValues'    = $FALSE;
                'HeaderPrint'     = $FALSE;
                'JumpToSummary'   = $FALSE;
                'Closing'         = $FALSE;
            }
        );
    }

    if ([string]::IsNullOrEmpty($InstallFile) -eq $FALSE) {
        $InstallCommand = Read-IcingaFileContent -File $InstallFile;
    }

    # Use our install command to configure everything
    if ([string]::IsNullOrEmpty($InstallCommand) -eq $FALSE) {

        Disable-IcingaFrameworkConsoleOutput;

        # Add our "old" swap internally
        $OldConfigSwap = Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap';

        [hashtable]$IcingaConfiguration = Convert-IcingaForwindowsManagementConsoleJSONConfig -Config (ConvertFrom-Json -InputObject $InstallCommand);

        # First run our configuration values
        Invoke-IcingaForWindowsManagementConsoleCustomConfig -IcingaConfiguration $IcingaConfiguration;

        # In case we use the director, we require to first fetch all basic values from the Self-Service API then
        # require to register the host to fet the remaining content
        if ($IcingaConfiguration.ContainsKey('IfW-DirectorSelfServiceKey') -And $IcingaConfiguration.ContainsKey('IfW-DirectorUrl')) {
            Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate;
            Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate -Register;
            Disable-IcingaFrameworkConsoleOutput;
        } else {
            # Now load all remaining values we haven't set and define the defaults
            Add-IcingaForWindowsInstallationAdvancedEntries;
        }

        # Now apply our configuration again to ensure the defaults are overwritten again
        # Suite a mess, but we can improve this later
        Invoke-IcingaForWindowsManagementConsoleCustomConfig -IcingaConfiguration $IcingaConfiguration;

        Enable-IcingaFrameworkConsoleOutput;

        Start-IcingaForWindowsInstallation -Automated;

        # Set our "old" swap live again. By doing so, we can still continue our old
        # configuration
        Set-IcingaPowerShellConfig -Path 'Framework.Config.Swap' -Value $OldConfigSwap;

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
                        'Caption' = 'Installation';
                        'Command' = 'Show-IcingaForWindowsInstallerMenuInstallWindows';
                        'Help'    = 'Allows you to install Icinga for Windows with all required components and options.'
                    },
                    @{
                        'Caption'  = 'Install components';
                        'Command'  = 'Show-IcingaForWindowsMenuInstallComponents';
                        'Help'     = 'Allows you to install new components for Icinga for Windows from your repositories.';
                        'Disabled' = (-Not ($global:Icinga.InstallWizard.AdminShell));
                    },
                    @{
                        'Caption'  = 'Update components';
                        'Command'  = 'Show-IcingaForWindowsMenuUpdateComponents';
                        'Help'     = 'Allows you to modify your current Icinga for Windows installation.';
                        'Disabled' = (-Not ($global:Icinga.InstallWizard.AdminShell));
                    },
                    @{
                        'Caption'  = 'Remove components';
                        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
                        'Help'     = 'Allows you to modify your current Icinga for Windows installation.';
                        'Disabled' = (-Not ($global:Icinga.InstallWizard.AdminShell));
                    },
                    @{
                        'Caption' = 'Manage environment';
                        'Command' = 'Show-IcingaForWindowsMenuManage';
                        'Help'    = 'Allows you to modify your current Icinga for Windows installation.';
                    },
                    @{
                        'Caption' = 'List environment';
                        'Command' = 'Show-IcingaForWindowsMenuListEnvironment';
                        'Help'    = 'Shows you an overview of your current Icinga for Windows installation, including installed components and system informations.';
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

                $global:Icinga.InstallWizard.LastError     = [string]::Format('Failed to enter menu "{0}". Error "{1}', $global:Icinga.InstallWizard.NextCommand, $ErrMsg);
                $global:Icinga.InstallWizard.NextCommand   = 'Install-Icinga';
                $global:Icinga.InstallWizard.NextArguments = @{ };
            }
        }
    }
}
