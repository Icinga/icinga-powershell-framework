function Set-IcingaForWindowsServiceJEAProfile()
{
    [string]$JeaProfile      = Get-IcingaJEAContext;
    $IcingaForWindowsService = Get-IcingaForWindowsServiceData;

    if ([string]::IsNullOrEmpty($IcingaForWindowsService.FullPath) -Or (Test-Path $IcingaForWindowsService.FullPath) -eq $FALSE) {
        return;
    }

    [string]$PreparedServicePath = [string]::Format(
        '\"{0}\" \"{1}\" \"{2}\"',
        $IcingaForWindowsService.FullPath,
        (Get-IcingaPowerShellModuleFile),
        $JeaProfile
    );

    $Result = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('config icingapowershell binPath= "{0}"', $PreparedServicePath));

    if ($Result.ExitCode -ne 0) {
        Write-IcingaConsoleError 'Failed to update Icinga for Windows service for JEA profile "{0}": {1}{2}' -Objects $JeaProfile, $ResolveStatus.Message, $ResolveStatus.Error;
    } else {
        Write-IcingaConsoleNotice 'Icinga for Windows service JEA handling has been configured successfully to profile "{0}"' -Objects $JeaProfile;
    }
}
