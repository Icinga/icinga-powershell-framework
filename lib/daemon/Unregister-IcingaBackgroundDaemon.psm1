function Unregister-IcingaBackgroundDaemon()
{
    param(
        [string]$BackgroundDaemon,
        [hashtable]$Arguments
    );

    if ([string]::IsNullOrEmpty($BackgroundDaemon)) {
        throw 'Please specify a Cmdlet to remove from running as Background Daemon';
    }

    $Path = [string]::Format('BackgroundDaemon.EnabledDaemons.{0}', $BackgroundDaemon);

    Remove-IcingaPowerShellConfig -Path $Path;

    Write-Host 'Background daemon has been removed';
}
