function Read-IcingaPowerShellConfig()
{
    $ConfigDir  = Get-IcingaPowerShellConfigDir;
    $ConfigFile = Join-Path -Path $ConfigDir -ChildPath 'config.json';

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon) {
        if ($global:IcingaDaemonData.ContainsKey('Config')) {
            return $global:IcingaDaemonData.Config;
        }
    }

    if (-Not (Test-Path $ConfigFile)) {
        return (New-Object -TypeName PSOBject);
    }

    [string]$Content = Get-Content -Path $ConfigFile;

    if ([string]::IsNullOrEmpty($Content)) {
        return (New-Object -TypeName PSOBject);
    }

    return (ConvertFrom-Json -InputObject $Content);
}
