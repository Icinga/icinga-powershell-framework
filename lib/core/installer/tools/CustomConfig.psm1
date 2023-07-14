function Invoke-IcingaForWindowsManagementConsoleCustomConfig()
{
    param (
        [hashtable]$IcingaConfiguration = @{ }
    );

    foreach ($cmd in $IcingaConfiguration.Keys) {
        $cmdConfig = $IcingaConfiguration[$cmd];

        if ($cmd.Contains(':')) {
            continue;
        }

        $cmdArguments = @{
            'Automated' = $TRUE;
        }

        if ($cmdConfig.ContainsKey('Values') -And $null -ne $cmdConfig.Values) {
            $cmdArguments.Add('Value', $cmdConfig.Values);
        }
        if ($cmdConfig.ContainsKey('Selection') -And $null -ne $cmdConfig.Selection) {
            $cmdArguments.Add('DefaultInput', $cmdConfig.Selection)
        }

        try {
            &$cmd @cmdArguments;
        } catch {
            Enable-IcingaFrameworkConsoleOutput;
            Write-IcingaConsoleError 'Failed to apply installation configuration of command "{0}" and argument list{1}because of the following error: "{2}"' -Objects $cmd, ($cmdArguments | Out-String), $_.Exception.Message;
            return $FALSE;
        }
    }

    return $TRUE;
}
