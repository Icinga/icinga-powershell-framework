function Set-IcingaPowerShellConfig()
{
    param(
        $Path  = '',
        $Value = $null
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Index   = $PathArray.Count;
    $InputValue   = $null;
    foreach ($entry in $PathArray) {
        if ($index -eq  1) {
            $InputValue = $Value;
        }
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            New-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry -ConfigValue $InputValue;
        }

        if ($index -eq  1) {
            $ConfigObject.$entry = $Value;
            break;
        }

        $ConfigObject = $ConfigObject.$entry;
        $index -= 1;
    }

    Write-IcingaPowerShellConfig $Config;
}
