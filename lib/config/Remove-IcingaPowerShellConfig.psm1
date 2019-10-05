function Remove-IcingaPowerShellConfig()
{
    param(
        $Path  = ''
    );

    if ([string]::IsNullOrEmpty($Path)) {
        throw 'Please specify a valid path to an object';
    }

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Index   = $PathArray.Count;

    foreach ($entry in $PathArray) {

        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            return $null;
        }

        if ($index -eq  1) {
            $ConfigObject.PSObject.Properties.Remove($entry);
            break;
        }

        $ConfigObject = $ConfigObject.$entry;
        $Index        -= 1;
    }

    Write-IcingaPowerShellConfig $Config;
}
