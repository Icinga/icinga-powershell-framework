function Unregister-IcingaServiceCheck()
{
    param(
        [string]$ServiceId
    );

    if ([string]::IsNullOrEmpty($ServiceId)) {
        throw 'Please specify a Service Id';
    }

    $Path = [string]::Format('BackgroundDaemon.RegisteredServices.{0}', $ServiceId);

    Remove-IcingaPowerShellConfig -Path $Path;

    Write-Host 'Icinga Service Check has been configured';
}
