function Invoke-IcingaForWindowsManagementConsoleCustomConfig()
{
    param (
        [hashtable]$IcingaConfiguration = @{ }
    );

    foreach ($cmd in $IcingaConfiguration.Keys) {
        $cmdConfig = $IcingaConfiguration[$cmd];

        if ($cmd.Contains(':')) {
            continue; # skip for now, as more complicated
        }

        $cmdArguments = @{
            'Automated' = $TRUE;
        }

        if ($cmdConfig.ContainsKey('Values') -And $null -ne $cmdConfig.Values) {
            $cmdArguments.Add('Value', $cmdConfig.Values)
        }
        if ($cmdConfig.ContainsKey('Selection') -And $null -ne $cmdConfig.Selection) {
            $cmdArguments.Add('DefaultInput', $cmdConfig.Selection)
        }

        &$cmd @cmdArguments;
    }
}
