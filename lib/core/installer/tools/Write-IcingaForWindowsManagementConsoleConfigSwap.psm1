function Write-IcingaforWindowsManagementConsoleConfigSwap()
{
    param (
        $Config = @{ }
    );

    [hashtable]$NewConfig = @{ };

    # Remove passwords - do not store them inside our local config file
    foreach ($entry in $Config.Keys) {
        $Value = $Config[$entry];

        $NewConfig.Add($entry, @{ });

        foreach ($configElement in $Value.Keys) {
            $confValue = $Value[$configElement];

            if ($Value.Password -eq $TRUE -And $configElement -eq 'Values') {
                $NewConfig[$entry].Add(
                    $configElement,
                    @( '***' )
                );
            } else {
                $NewConfig[$entry].Add(
                    $configElement,
                    $confValue
                );
            }
        }
    }

    Set-IcingaPowerShellConfig -Path 'Framework.Config.Swap' -Value $NewConfig;
}
