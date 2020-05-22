function Show-IcingaDirecorSelfServiceKey()
{
    $Path  = 'IcingaDirector.SelfService.ApiKey';
    $Value = Get-IcingaPowerShellConfig $Path;

    if ($null -ne $Value) {
        Write-IcingaConsoleNotice ([string]::Format('Self-Service Key: "{0}"', $Value));
    } else {
        Write-IcingaConsoleWarning 'There is no Self-Service Api key configured on this system';
    }
}
