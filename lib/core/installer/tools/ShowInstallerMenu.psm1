function Show-IcingaForWindowsInstallerMenu()
{
    param (
        [string]$Header,
        [array]$Entries,
        [array]$DefaultValues        = @(),
        [string]$DefaultIndex        = $null,
        [string]$ParentConfig        = $null,
        [switch]$AddConfig           = $FALSE,
        [switch]$PasswordInput       = $FALSE,
        [switch]$ContinueFirstValue  = $FALSE,
        [switch]$MandatoryValue      = $FALSE,
        [int]$ConfigLimit            = -1,
        [switch]$JumpToSummary       = $FALSE,
        [string]$ContinueFunction    = $null,
        [switch]$ConfigElement       = $FALSE,
        [switch]$HiddenConfigElement = $FALSE,
        [switch]$ReadOnly            = $FALSE,
        [switch]$Automated           = $FALSE,
        [switch]$Advanced            = $FALSE,
        [switch]$PlainTextOutput     = $FALSE
    );

    if ((Test-IcingaForWindowsInstallationHeaderPrint) -eq $FALSE -And (Get-IcingaFrameworkDebugMode) -eq $FALSE) {
        Clear-Host;
    }

    $PSCallStack   = Get-PSCallStack;
    $LastArguments = $null;
    $LastCommand   = $null;

    if ($PSCallStack.Count -gt 1) {
        $LastCommand   = $PSCallStack[1].Command;
        $LastArguments = $PSCallStack[1].InvocationInfo.BoundParameters;

        # Only keep internal values as long as we are navigating within the same menu
        if ($global:Icinga.InstallWizard.Menu -ne $LastCommand) {
            $global:Icinga.InstallWizard.LastValues = @();
        }

        # Prevent from adding ourself because of stack calls.
        # This should always be the "real" last command
        if ($LastCommand -ne 'Show-IcingaForWindowsInstallerMenu') {
            $global:Icinga.InstallWizard.Menu = $LastCommand;
        } else {
            $LastCommand = Get-IcingaForWindowsManagementConsoleMenu;
        }
    }

    $SelectionForCurrentMenu                  = Get-IcingaForWindowsInstallerStepSelection -InstallerStep (Get-IcingaForWindowsManagementConsoleMenu);
    [bool]$EntryModified                      = $FALSE;
    [int]$EntryIndex                          = 0;
    [hashtable]$KnownIndexes                  = @{ };
    $LastParent                               = Get-IcingaForWindowsInstallerLastParent;
    [array]$StoredValues                      = (Get-IcingaForWindowsInstallerValuesFromStep);
    $global:Icinga.InstallWizard.ParentConfig = $ParentConfig;
    $global:Icinga.InstallWizard.LastInput    = $null;

    if ($LastParent -eq (Get-IcingaForWindowsManagementConsoleAlias -Command $LastCommand)) {
        Remove-IcingaForWindowsInstallerLastParent;
        $LastParent = Get-IcingaForWindowsInstallerLastParent;
    }

    if (Test-IcingaForWindowsInstallationJumpToSummary) {
        $SelectionForCurrentMenu = $null;
    }

    if (($StoredValues.Count -eq 0 -And $DefaultValues.Count -ne 0) -Or $Automated) {
        $StoredValues = $DefaultValues;
    }

    if ($global:Icinga.InstallWizard.DeleteValues) {
        $StoredValues = @();
        $global:Icinga.InstallWizard.DeleteValues = $FALSE;
    }

    if ((Test-IcingaForWindowsInstallationHeaderPrint) -eq $FALSE) {

        $ConsoleHeaderLines = @(
            'Icinga for Windows Management Console',
            'Copyright $Copyright',
            'User environment $UserDomain\$Username',
            'Icinga PowerShell Framework $FrameworkVersion'
        );

        if ($global:Icinga.InstallWizard.AdminShell -eq $FALSE) {
            $ConsoleHeaderLines += '[Warning]: Run this shell with administrative privileges to unlock all features'
        }

        if ($PSVersionTable.PSVersion -lt '5.0.0.0') {
            $ConsoleHeaderLines += ([string]::Format('[Warning]: Update to PowerShell version >=5.0 from currently {0} to unlock all features (like JEA)', $PSVersionTable.PSVersion.ToString(2)));
        }

        Write-IcingaConsoleHeader -HeaderLines $ConsoleHeaderLines;

        Write-IcingaConsolePlain '';
        Write-IcingaConsolePlain $Header;

        Write-IcingaConsolePlain '';
    }

    foreach ($entry in $Entries) {
        if ([string]::IsNullOrEmpty($entry.Caption) -eq $FALSE) {
            $Header    = ([string]::Format('[{0}] {1}', $EntryIndex, $entry.Caption));
            $FontColor = 'Default';

            if ((Test-IcingaForWindowsInstallationHeaderPrint) -eq $FALSE) {
                # Highlight the default index in a different color
                if ($DefaultIndex -eq $EntryIndex) {
                    $FontColor = 'Cyan';
                }

                # In case a entry is disabled, highlight it differently
                if ($null -ne $entry.Disabled -And $entry.Disabled -eq $TRUE) {
                    $FontColor = 'DarkGray';
                }

                # Mark our previous selection in another color for better highlighting
                if ($null -ne $SelectionForCurrentMenu -And $SelectionForCurrentMenu -eq $EntryIndex) {
                    $FontColor = 'Green';
                }

                Write-IcingaConsolePlain $Header -ForeColor $FontColor;

                if ($global:Icinga.InstallWizard.ShowHelp -And ([string]::IsNullOrEmpty($entry.Help)) -eq $FALSE) {
                    Write-IcingaConsolePlain '';
                    Write-IcingaConsolePlain $entry.Help -ForeColor Magenta;
                    Write-IcingaConsolePlain '';
                }
            } else {
                if ((Get-IcingaForWindowsInstallationHeaderSelection) -eq $EntryIndex) {
                    $global:Icinga.InstallWizard.HeaderPreview = $entry.Caption;
                    return;
                }
            }
        }

        $KnownIndexes.Add([string]$EntryIndex, $TRUE);
        $EntryIndex += 1;
    }

    if ((Test-IcingaForWindowsInstallationHeaderPrint)) {
        return;
    }

    if ($StoredValues.Count -ne 0) {
        if ($PlainTextOutput) {
            Write-IcingaConsolePlain (ConvertFrom-IcingaArrayToString -Array $StoredValues) -ForeColor Cyan;
        } else {
            if ($PasswordInput -eq $FALSE) {
                Write-IcingaConsolePlain ([string]::Format(' {0}', (ConvertFrom-IcingaArrayToString -Array $StoredValues -AddQuotes))) -ForeColor Cyan;
            } else {
                Write-IcingaConsolePlain ([string]::Format(' {0}', (ConvertFrom-IcingaArrayToString -Array $StoredValues -AddQuotes -SecureContent))) -ForeColor Cyan;
            }
        }
    }

    if ($AddConfig) {
        if ($global:Icinga.InstallWizard.ShowHelp -And ([string]::IsNullOrEmpty($Entries[0].Help)) -eq $FALSE) {
            Write-IcingaConsolePlain '';
            Write-IcingaConsolePlain $entry.Help -ForeColor Magenta;
        }
    }

    Write-IcingaConsolePlain '';
    Write-IcingaConsolePlain '[x] Exit' -NoNewLine;

    if ($global:Icinga.InstallWizard.DisplayAdvanced) {
        if ($global:Icinga.InstallWizard.ShowAdvanced -eq $FALSE) {
            Write-IcingaConsolePlain ' [a] Advanced' -NoNewLine;
        } else {
            Write-IcingaConsolePlain ' [a] Hide Advanced' -NoNewLine -ForeColor Green;
        }
    }

    Write-IcingaConsolePlain ' [c] Continue' -NoNewLine;

    if ($AddConfig -And $ReadOnly -eq $FALSE) {
        Write-IcingaConsolePlain ' [d] Delete' -NoNewLine;
    }

    if ($global:Icinga.InstallWizard.ShowHelp -eq $FALSE) {
        Write-IcingaConsolePlain ' [h] Help [m] Main' -NoNewLine;
    } else {
        Write-IcingaConsolePlain ' [h] Hide Help' -NoNewLine -ForeColor Green;
        Write-IcingaConsolePlain ' [m] Main' -NoNewLine;
    }

    if ([string]::IsNullOrEmpty($LastParent) -eq $FALSE -Or $global:Icinga.InstallWizard.LastParent.Count -gt 1) {
        Write-IcingaConsolePlain ' [p] Previous';
    } else {
        Write-IcingaConsolePlain '';
    }

    $Prompt      = 'Input';
    $CountPrompt = ([string]::Format('({0}/{1})', $StoredValues.Count, $ConfigLimit));
    if ($ConfigLimit -eq -1) {
        $CountPrompt = ([string]::Format('({0} values)', $StoredValues.Count));
    }

    if ($AddConfig) {
        $Prompt = ([string]::Format('Input {0}', $CountPrompt));
        # In case we reached the maximum entries, set c as default input for easier handling
        if (($ConfigLimit -le $StoredValues.Count) -Or ($ContinueFirstValue -eq $TRUE -And $StoredValues.Count -ge 1)) {
            $DefaultIndex = 'c';
        }
    }

    if ([string]::IsNullOrEmpty($DefaultIndex) -eq $FALSE) {
        if ((Test-Numeric $DefaultIndex)) {
            $Prompt = [string]::Format('Input (Default {0} and c)', $DefaultIndex);
        } else {
            $Prompt = [string]::Format('Input (Default {0})', $DefaultIndex);
        }
        if ($AddConfig) {
            $Prompt = [string]::Format('{0} {1}', $Prompt, $CountPrompt);
        }
    }

    Write-IcingaConsolePlain '';

    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastError) -eq $FALSE) {
        Write-IcingaConsoleError ($global:Icinga.InstallWizard.LastError);
        $global:Icinga.InstallWizard.LastError = '';
        Write-IcingaConsolePlain '';
    }

    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastNotice) -eq $FALSE) {
        Write-IcingaConsoleNotice ($global:Icinga.InstallWizard.LastNotice);
        $global:Icinga.InstallWizard.LastNotice = '';
        Write-IcingaConsolePlain '';
    }

    if ($Automated -eq $FALSE) {
        $Result = Read-Host -Prompt $Prompt -AsSecureString:$PasswordInput;

        # Translate the value back to check what we used for input. We are not going to share
        # the content however
        if ($PasswordInput) {
            $Result = ConvertFrom-IcingaSecureString -SecureString $Result;
        }

        if ([string]::IsNullOrEmpty($Result) -And [string]::IsNullOrEmpty($DefaultIndex) -eq $FALSE) {
            $Result = $DefaultIndex;
        }
    } else {
        if ([string]::IsNullOrEmpty($DefaultIndex) -eq $FALSE) {
            $Result = $DefaultIndex;
        }
    }

    $global:Icinga.InstallWizard.NextCommand   = $LastCommand;
    $global:Icinga.InstallWizard.NextArguments = $LastArguments;
    $global:Icinga.InstallWizard.LastInput     = $Result;

    switch ($Result) {
        'x' {
            Clear-Host;
            $global:Icinga.InstallWizard.Closing = $TRUE;
            return;
        };
        'a' {
            $global:Icinga.InstallWizard.ShowAdvanced = (-Not ($global:Icinga.InstallWizard.ShowAdvanced));
            return;
        };
        'h' {
            $global:Icinga.InstallWizard.ShowHelp = (-Not ($global:Icinga.InstallWizard.ShowHelp));

            return;
        };
        'm' {
            $global:Icinga.InstallWizard.NextCommand   = $null;
            $global:Icinga.InstallWizard.NextArguments = $null;

            return;
        }
        'p' {
            if ([string]::IsNullOrEmpty($LastParent) -eq $FALSE) {
                Remove-IcingaForWindowsInstallerLastParent;

                $global:Icinga.InstallWizard.NextCommand   = $LastParent;
                $global:Icinga.InstallWizard.NextArguments = $null;

                return;
            }

            $global:Icinga.InstallWizard.LastError = 'You cannot move to the previous menu from here.';
            if ($global:Icinga.InstallWizard.LastParent.Count -eq 0) {
                $global:Icinga.InstallWizard.NextCommand   = $null;
                $global:Icinga.InstallWizard.NextArguments = $null;

                return;
            }

            return;
        };
        'd' {
            if ($ReadOnly -eq $FALSE) {
                $StoredValues = @();
                Clear-IcingaForWindowsInstallerValuesFromStep
                $global:Icinga.InstallWizard.DeleteValues = $TRUE;
                $global:Icinga.InstallWizard.LastValues = @();
            }

            return;
        };
        'c' {
            if ($MandatoryValue -And $StoredValues.Count -eq 0) {
                $global:Icinga.InstallWizard.LastError = 'You need to add at least one value!';

                return;
            }

            if ($AddConfig -eq $FALSE) {
                $Result = $DefaultIndex;
                $global:Icinga.InstallWizard.LastInput = $Result;
            }

            $global:Icinga.InstallWizard.LastValues = $StoredValues;

            break;
        };
        default {
            if ($AddConfig) {

                if ($ConfigLimit -eq -1 -Or $ConfigLimit -gt $StoredValues.Count) {
                    if ([string]::IsNullOrEmpty($Result) -eq $FALSE) {

                        $StoredValues += $Result;
                        if ($ConfigElement) {
                            Add-IcingaForWindowsInstallerConfigEntry -Values $StoredValues -Hidden:$HiddenConfigElement -PasswordInput:$PasswordInput -Advanced:$Advanced;
                        }

                        $global:Icinga.InstallWizard.LastValues = $StoredValues;
                    } else {
                        if ($DefaultValues.Count -ne 0) {
                            $global:Icinga.InstallWizard.LastNotice = 'Empty values are not allowed! Resetting to default.';
                        } else {
                            $global:Icinga.InstallWizard.LastError = 'You cannot add an empty value!';
                        }
                    }
                } else {
                    $global:Icinga.InstallWizard.LastError = [string]::Format('You can only add {0} value(s)', $ConfigLimit);
                }

                return;
            }
            if ((Test-Numeric $Result) -eq $FALSE -Or $KnownIndexes.ContainsKey([string]$Result) -eq $FALSE) {
                $global:Icinga.InstallWizard.LastError = [string]::Format('Invalid selection has been made: {0}', $Result);

                return;
            }

            break;
        };
    }

    $DisabledMenu  = $FALSE;
    $NextMenu      = $null;
    $NextArguments = @{ };
    $ActionCmd     = $null;
    $ActionArgs    = $null;

    if ([string]::IsNullOrEmpty($Result) -eq $FALSE) {
        if ($Result -eq 'c') {
            if ([string]::IsNullOrEmpty($ContinueFunction) -eq $FALSE) {
                $NextMenu = $ContinueFunction;
            } else {
                $NextMenu = $Entries[0].Command;
                if ($null -ne $Entries[0].Disabled) {
                    $DisabledMenu = $Entries[0].Disabled;
                }
            }
            $ActionCmd  = $Entries[0].Action.Command;
            $ActionArgs = $Entries[0].Action.Arguments;
        } else {
            $NextMenu = $Entries[$Result].Command;
            if ($null -ne $Entries[$Result].Disabled) {
                $DisabledMenu = $Entries[$Result].Disabled;
            }
            if ($Entries[$Result].ContainsKey('Arguments')) {
                $NextArguments = $Entries[$Result].Arguments;
            }
            $ActionCmd  = $Entries[$Result].Action.Command;
            $ActionArgs = $Entries[$Result].Action.Arguments;
        }
    }

    if ($DisabledMenu) {
        $global:Icinga.InstallWizard.LastNotice = [string]::Format('This menu is not enabled: {0}', $Result);

        return;
    }

    if ([string]::IsNullOrEmpty($NextMenu)) {
        $global:Icinga.InstallWizard.LastNotice = [string]::Format('This menu is not yet implemented: {0}', $Result);

        return;
    }

    if ($Advanced -eq $FALSE) {
        Add-IcingaForWindowsManagementConsoleLastParent;
    }

    if ($JumpToSummary) {
        $NextMenu = 'Show-IcingaForWindowsInstallerConfigurationSummary';
    }

    if ($ConfigElement) {
        Add-IcingaForWindowsInstallerConfigEntry `
            -InstallerStep (Get-IcingaForWindowsManagementConsoleMenu) `
            -Selection $Result `
            -Values $StoredValues `
            -Hidden:$HiddenConfigElement `
            -PasswordInput:$PasswordInput `
            -Advanced:$Advanced;
    }

    # Reset Help View
    $global:Icinga.InstallWizard.ShowHelp = $FALSE;

    if ($NextMenu -eq 'break') {
        return;
    }

    $global:Icinga.InstallWizard.NextCommand   = $NextMenu;
    $global:Icinga.InstallWizard.NextArguments = $NextArguments;

    if ($Automated) {
        return;
    }

    # In case a action is defined, execute the given action
    if ([string]::IsNullOrEmpty($ActionCmd) -eq $FALSE) {
        if ($null -eq $ActionArgs -Or $ActionArgs.Count -eq 0) {
            $ActionArgs = @{ };
        }

        & $ActionCmd @ActionArgs | Out-Null;
    }
}
