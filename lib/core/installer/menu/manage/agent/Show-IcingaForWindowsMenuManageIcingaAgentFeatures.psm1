function Show-IcingaForWindowsMenuManageIcingaAgentFeatures()
{
    $Features = Get-IcingaAgentFeatures;

    [array]$FeatureList = @();

    foreach ($entry in $Features.Enabled) {

        if ([string]::IsNullOrEmpty($entry)) {
            continue;
        }

        [string]$Caption = [string]::Format('{0}: Enabled', $entry);

        $FeatureList += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgentFeatures';
            'Help'     = ([string]::Format('The feature "{0}" is currently enabled. Select this entry to disable it.', $entry));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Disable-IcingaAgentFeature';
                'Arguments' = @{
                    '-Feature' = $entry;
                }
            }
        }
    }

    foreach ($entry in $Features.Disabled) {

        if ([string]::IsNullOrEmpty($entry)) {
            continue;
        }

        [string]$Caption = [string]::Format('{0}: Disabled', $entry);

        $FeatureList += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgentFeatures';
            'Help'     = ([string]::Format('The feature "{0}" is currently disabled. Select this entry to enable it.', $entry));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Enable-IcingaAgentFeature';
                'Arguments' = @{
                    '-Feature' = $entry;
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga Agent Features. Select an entry and hit enter to Disable/Enable them:' `
        -Entries $FeatureList;
}
