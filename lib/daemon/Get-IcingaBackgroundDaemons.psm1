function Get-IcingaBackgroundDaemons()
{
    $Daemons = Get-IcingaPowerShellConfig -Path 'BackgroundDaemon.EnabledDaemons';

    if ($null -eq $Daemons) {
        return $null;
    }

    [hashtable]$Output = @{};

    foreach ($daemon in $Daemons.PSObject.Properties) {
        $Arguments = @{ };

        foreach ($argument in $daemon.Value.Arguments.PSObject.Properties) {
            $Arguments.Add($argument.Name, $argument.Value);
        }

        $Output.Add($daemon.Name, $Arguments);
    }

    return $Output;
}
