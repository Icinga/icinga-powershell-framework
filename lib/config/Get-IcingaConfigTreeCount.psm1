function Get-IcingaConfigTreeCount()
{
    param(
        $Path = ''
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Count   = 0;

    foreach ($entry in $PathArray) {
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            continue;
        }

        $ConfigObject = $ConfigObject.$entry;
    }

    foreach ($config in $ConfigObject.PSObject.Properties) {
        $Count += 1;
    }

    return $Count;
}
