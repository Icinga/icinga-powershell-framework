function Register-IcingaBackgroundDaemon()
{
    param(
        [string]$Command,
        [hashtable]$Arguments
    );

    if ([string]::IsNullOrEmpty($Command)) {
        throw 'Please specify a Cmdlet to run as Background Daemon';
    }

    if (-Not (Test-IcingaFunction $Command)) {
        throw ([string]::Format('The Cmdlet "{0}" is not available in your session. Please restart the session and try again or verify your input', $Command));
    }

    $Path = [string]::Format('BackgroundDaemon.EnabledDaemons.{0}', $Command);

    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Command', $Path)) -Value $Command;
    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Arguments', $Path)) -Value $Arguments;

    Write-Host ([string]::Format('Background daemon Cmdlet "{0}" has been configured', $Command));
}
