function Register-IcingaServiceCheck()
{
    param(
        [string]$CheckCommand,
        [hashtable]$Arguments,
        [int]$Interval        = 60,
        [array]$TimeIndexes   = @()
    );

    if ([string]::IsNullOrEmpty($CheckCommand)) {
        throw 'Please specify a CheckCommand';
    }

    $Hash = Get-StringSha1 ([string]::Format('{0} {1}', $CheckCommand, ($Arguments | Out-String)));
    $Path = [string]::Format('BackgroundDaemon.RegisteredServices.{0}', $Hash);

    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.CheckCommand', $Path)) -Value $CheckCommand;
    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Arguments', $Path)) -Value $Arguments;
    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Interval', $Path)) -Value $Interval;
    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.TimeIndexes', $Path)) -Value $TimeIndexes;

    Write-IcingaConsoleNotice 'Icinga Service Check has been configured';
}
