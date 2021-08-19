function Show-IcingaForWindowsInstallerConfigurationSummary()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    [array]$Entries      = @();
    [int]$CurrentIndex   = 0
    [int]$MaxEntryLength = (Get-IcingaMaxTextLength -TextArray $global:Icinga.InstallWizard.Config.Keys) - 4;

    Enable-IcingaForWindowsInstallationHeaderPrint;

    while ($TRUE) {
        if ($CurrentIndex -gt $global:Icinga.InstallWizard.Config.Count) {
            break;
        }

        foreach ($entry in $global:Icinga.InstallWizard.Config.Keys) {
            $ConfigEntry = $global:Icinga.InstallWizard.Config[$entry];

            if ($ConfigEntry.Index -ne $CurrentIndex) {
                continue;
            }

            if ($ConfigEntry.Hidden) {
                continue;
            }

            if ($ConfigEntry.Advanced -And $global:Icinga.InstallWizard.ShowAdvanced -eq $FALSE) {
                continue;
            }

            $EntryValue = $ConfigEntry.Selection;
            if ($null -ne $ConfigEntry.Values -And $ConfigEntry.Count -ne 0) {
                if ($ConfigEntry.Password) {
                    $EntryValue = ConvertFrom-IcingaArrayToString -Array $ConfigEntry.Values -AddQuotes -SecureContent;
                } else {
                    $EntryValue = ConvertFrom-IcingaArrayToString -Array $ConfigEntry.Values -AddQuotes;
                }
            }

            [string]$Caption = ''
            $PrintName       = $entry;
            $RealCommand     = $entry;
            $ChildElement    = '';

            if ($RealCommand.Contains(':')) {
                $RealCommand  = $entry.Split(':')[0];
                $ChildElement = $entry.Split(':')[1];
            }

            if ($entry.Contains(':')) {
                $PrintName = [string]::Format('{0} for "{1}"', $RealCommand, $ChildElement);
            } else {
                $PrintName = $RealCommand;
            }

            $PrintName = $PrintName.Replace('IfW-', '');
            $PrintName = Add-IcingaWhiteSpaceToString -Text $PrintName -Length $MaxEntryLength;

            if (Test-Numeric ($ConfigEntry.Selection)) {
                Set-IcingaForWindowsInstallationHeaderSelection -Selection $ConfigEntry.Selection;

                try {
                    &$RealCommand;
                } catch {
                    $ErrMsg = [string]::Format('Failed to apply configuration item "{0}". This could happen in case elements were removed or renamed between Framework versions: {1}', $RealCommand, $_.Exception.Message);
                    $global:Icinga.InstallWizard.LastError += $ErrMsg;
                    continue;
                }

                $Caption = ([string]::Format('{0}=> {1}', $PrintName, $global:Icinga.InstallWizard.HeaderPreview));
            } else {
                $Caption = ([string]::Format('{0}=> {1}', $PrintName, $EntryValue));
            }

            $Entries += @{
                'Caption'   = $Caption;
                'Command'   = $entry;
                'Arguments' = @{ '-JumpToSummary' = $TRUE };
                'Help'      = ''
            }

            $global:Icinga.InstallWizard.HeaderPreview = '';
        }

        $CurrentIndex += 1;
    }

    Write-Host 'Finished'

    Disable-IcingaForWindowsInstallationHeaderPrint;
    Enable-IcingaForWindowsInstallationJumpToSummary;

    $global:Icinga.InstallWizard.DisplayAdvanced = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please validate your configuration. Installation starts on continue:' `
        -Entries $Entries `
        -DefaultIndex 'c' `
        -ContinueFunction 'Show-IcingaForWindowsInstallerMenuFinishInstaller' `
        -ConfigElement `
        -Hidden;

    Disable-IcingaForWindowsInstallationJumpToSummary;
    $global:Icinga.InstallWizard.DisplayAdvanced = $FALSE;
}

Set-Alias -Name 'IfW-ConfigurationSummary' -Value 'Show-IcingaForWindowsInstallerConfigurationSummary';
