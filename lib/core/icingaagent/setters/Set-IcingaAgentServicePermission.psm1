function Set-IcingaAgentServicePermission()
{
    if (Test-IcingaAgentServicePermission -Silent) {
        Write-IcingaConsoleNotice 'The Icinga Service User already has permission to run as service';
        return;
    }

    $SystemPermissions = New-IcingaTemporaryFile;
    $ServiceUser       = Get-IcingaServiceUser;
    $ServiceUserSID    = Get-IcingaUserSID $ServiceUser;
    $SystemContent     = Get-IcingaAgentServicePermission;
    $NewSystemContent  = @();

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'There is no user assigned to the Icinga 2 service or the service is not yet installed';
        return $FALSE;
    }

    foreach ($line in $SystemContent) {
        if ($line -like '*SeServiceLogonRight*') {
            $line = [string]::Format('{0},*{1}', $line, $ServiceUserSID);
        }

        $NewSystemContent += $line;
    }

    Write-IcingaFileSecure -File "$SystemPermissions.inf" -Value $NewSystemContent;

    $SystemOutput = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/import /cfg "{0}.inf" /db "{0}.sdb"', $SystemPermissions));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to import system permission information: {0}', $SystemOutput.Message));
        return $null;
    }

    $SystemOutput = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/configure /cfg "{0}.inf" /db "{0}.sdb"', $SystemPermissions));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to configure system permission information: {0}', $SystemOutput.Message));
        return $null;
    }

    Remove-Item $SystemPermissions*;

    Test-IcingaAgentServicePermission | Out-Null;
}
