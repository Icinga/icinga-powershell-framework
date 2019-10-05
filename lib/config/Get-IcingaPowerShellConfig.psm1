function Get-IcingaPowerShellConfig()
{
    param(
        $Path = ''
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;

    foreach ($entry in $PathArray) {
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            return $null;
        }

        $ConfigObject = $ConfigObject.$entry;
    }

    return $ConfigObject;
}
