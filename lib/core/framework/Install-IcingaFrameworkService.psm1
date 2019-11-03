function Install-IcingaFrameworkService()
{
    param(
        $Path,
        $User,
        [SecureString]$Password
    );

    if ([string]::IsNullOrEmpty($Path)) {
        Write-Host 'No path specified for Framework service. Service will not be installed';
        return;
    }

    if ((Test-Path $Path) -eq $FALSE) {
        throw 'Please specify the path directly to the service binary';
    }

    $Path = [string]::Format(
        '{0} \"{1}\"',
        $Path,
        (Get-IcingaPowerShellModuleFile)
    );

    $ServiceCreation = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('create icingapowershell binPath= "{0}" DisplayName= "Icinga PowerShell Service" start= auto', $Path));

    if ($ServiceCreation.ExitCode -ne 0) {
        throw ([string]::Format('Failed to install Icinga PowerShell Service: {0}{1}', $ServiceCreation.Message, $ServiceCreation.Error));
    }

    # This is just a hotfix to ensure we setup the service properly before assigning it to
    # a proper user, like 'NT Authority\NetworkService'. For some reason the NetworkService
    # will not start without this workaround.
    # Todo: Figure out the reason and fix it properly
    Set-IcingaAgentServiceUser -User 'LocalSystem' -Service 'icingapowershell' | Out-Null;

    return (Set-IcingaAgentServiceUser -User $User -Password $Password -Service 'icingapowershell');
}
