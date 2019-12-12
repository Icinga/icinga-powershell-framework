function Remove-IcingaDirectorSelfServiceKey()
{
    $Path  = 'IcingaDirector.SelfService.ApiKey';
    $Value = Get-IcingaPowerShellConfig $Path;
    if ($null -ne $Value) {
        Remove-IcingaPowerShellConfig 'IcingaDirector.SelfService.ApiKey';
        $Value = Get-IcingaPowerShellConfig $Path;
        if ($null -eq $Value) {
            Write-Host 'Icinga Director Self-Service Api key was successfully removed. Please dont forget to drop it within the Icinga Director as well';
        }
    } else {
        Write-Host 'There is no Self-Service Api key configured on this system';
    }
}
