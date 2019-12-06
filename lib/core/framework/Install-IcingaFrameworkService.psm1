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

    $UpdateFile = [string]::Format('{0}.update', $Path);

    $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;

    if ((Test-Path $UpdateFile)) {

        Write-Host 'Updating Icinga PowerShell Service binary';

        if ($ServiceStatus -eq 'Running') {
            Write-Host 'Stopping Icinga PowerShell service';
            Stop-IcingaService 'icingapowershell';
            Start-Sleep -Seconds 1;
        }

        Remove-ItemSecure -Path $Path -Force | Out-Null;
        Copy-ItemSecure -Path $UpdateFile -Destination $Path -Force | Out-Null;
        Remove-ItemSecure -Path $UpdateFile -Force | Out-Null;
    }

    if ((Test-Path $Path) -eq $FALSE) {
        throw 'Please specify the path directly to the service binary';
    }

    $Path = [string]::Format(
        '{0} \"{1}\"',
        $Path,
        (Get-IcingaPowerShellModuleFile)
    );

    if ($null -eq $ServiceStatus) {
        $ServiceCreation = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('create icingapowershell binPath= "{0}" DisplayName= "Icinga PowerShell Service" start= auto', $Path));

        if ($ServiceCreation.ExitCode -ne 0) {
            throw ([string]::Format('Failed to install Icinga PowerShell Service: {0}{1}', $ServiceCreation.Message, $ServiceCreation.Error));
        }
    } else {
        Write-Host 'The Icinga PowerShell Service is already installed';
    }

    # This is just a hotfix to ensure we setup the service properly before assigning it to
    # a proper user, like 'NT Authority\NetworkService'. For some reason the NetworkService
    # will not start without this workaround.
    # Todo: Figure out the reason and fix it properly
    Set-IcingaAgentServiceUser -User 'LocalSystem' -Service 'icingapowershell' | Out-Null;
    Restart-IcingaService 'icingapowershell';
    Start-Sleep -Seconds 1;
    Stop-IcingaService 'icingapowershell';

    if ($ServiceStatus -eq 'Running') {
        Write-Host 'Starting Icinga PowerShell service';
        Start-IcingaService 'icingapowershell';
        Start-Sleep -Seconds 1;
    }

    return (Set-IcingaAgentServiceUser -User $User -Password $Password -Service 'icingapowershell');
}
