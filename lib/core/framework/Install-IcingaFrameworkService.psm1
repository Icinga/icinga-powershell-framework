function Install-IcingaFrameworkService()
{
    param(
        $Path,
        $User,
        [SecureString]$Password
    );

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

    return (Set-IcingaAgentServiceUser -User $User -Password $Password -Service 'icingapowershell');
}
