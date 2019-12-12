function Show-IcingaDirecorSelfServiceKey()
{
    $Path  = 'IcingaDirector.SelfService.ApiKey';
    $Value = Get-IcingaPowerShellConfig $Path;

    if ($null -ne $Value) {
        Write-Host ([string]::Format('Self-Service Key: "{0}"', $Value));
    } else {
        Write-Host 'There is no Self-Service Api key configured on this system';
    }
}
