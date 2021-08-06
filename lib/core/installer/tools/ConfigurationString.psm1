function Get-IcingaForWindowsManagementConsoleConfigurationString()
{
    param (
        [switch]$Compress = $FALSE
    );

    [hashtable]$Configuration = @{ };

    foreach ($entry in $Global:Icinga.InstallWizard.Config.Keys) {
        $Value = $Global:Icinga.InstallWizard.Config[$entry];

        # Only print arguments that contain changes
        if ($Value.Modified -eq $FALSE) {
            continue;
        }

        $Command = $entry;
        $Parent  = $null;

        # Handle configurations with parent dependencies
        if ($entry.Contains(':')) {
            $KeyValue = $entry.Split(':');
            $Command  = $KeyValue[0];
            $Parent   = $KeyValue[1];
        }

        if ($Configuration.ContainsKey($Command) -eq $FALSE) {
            $Configuration.Add($Command, @{ });
        }

        # No parent exist, just add the values
        if ([string]::IsNullOrEmpty($Parent)) {
            if ($null -ne $Value.Values -And $Value.Values.Count -ne 0) {
                [array]$ConfigValues = @();

                foreach ($element in $Value.Values) {
                    if ([string]::IsNullOrEmpty($element) -eq $FALSE) {
                        $ConfigValues += $element;
                    }
                }

                if ($ConfigValues.Count -ne 0) {
                    $Configuration[$Command].Add(
                        'Values', $ConfigValues
                    );
                }
            }
        } else {
            # Handle parent references
            [hashtable]$ParentConfig = @{ };

            if ($Configuration[$Command].ContainsKey('Values')) {
                $ParentConfig = $Configuration[$Command].Values;
            }

            $ParentConfig.Add(
                $Value.ParentEntry,
                $Value.Values
            );

            $Configuration[$Command].Values = $ParentConfig;
        }

        if ($Configuration[$Command].ContainsKey('Selection')) {
            continue;
        }

        if ([string]::IsNullOrEmpty($Value.Selection) -eq $FALSE -And $Value.Selection -ne 'c') {
            $Configuration[$Command].Add(
                'Selection', $Value.Selection
            );
        }

        if ($Configuration[$Command].Count -eq 0) {
            $Configuration.Remove($Command);
        }
    }

    return ($Configuration | ConvertTo-Json -Depth 100 -Compress:$Compress);
}
