function Update-IcingaWindowsUserPermission()
{
    param (
        [string]$SID    = '',
        [switch]$Remove = $FALSE
    );

    if ([string]::IsNullOrEmpty($SID)) {
        Write-IcingaConsoleError 'You have to specify the SID of the user to set the security profile to';
        return;
    }

    if ($SID.Length -le 16) {
        Write-IcingaConsoleWarning 'It seems the provided SID "{0}" is a system SID. Skipping permission update' -Objects $SID;
        return;
    }

    if ((Test-IcingaManagedUser -SID $SID) -eq $FALSE) {
        Write-IcingaConsoleWarning 'This user is not managed by Icinga directly. Skipping permission update';
        return;
    }

    $UpdatedProfile     = New-IcingaTemporaryFile;
    $SystemOutput       = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/export /cfg "{0}.inf"', $UpdatedProfile));
    $NewSecurityProfile = @();

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to fetch security profile: {0}', $SystemOutput.Message));
        return;
    }

    $SecurityProfile = '';

    if ($Remove -eq $FALSE) {
        $SecurityProfile = Get-Content "$UpdatedProfile.inf";

        foreach ($line in $SecurityProfile) {
            if ($line -like '*SeServiceLogonRight*') {
                $line = [string]::Format('{0},*{1}', $line, $SID);
            }
            if ($line -like '*SeDenyNetworkLogonRight*') {
                $line = [string]::Format('{0},*{1}', $line, $SID);
            }
            if ($line -like '*SeDenyInteractiveLogonRight*') {
                $line = [string]::Format('{0},*{1}', $line, $SID);
            }

            $NewSecurityProfile += $line;
        }
    } else {
        $SecurityProfile    = Get-Content "$UpdatedProfile.inf" -Raw;
        $SecurityProfile    = $SecurityProfile.Replace([string]::Format(',*{0}', $SID), '');
        $SecurityProfile    = $SecurityProfile.Replace([string]::Format('*{0},', $SID), '');
        $NewSecurityProfile = $SecurityProfile;
    }

    Set-Content -Path "$UpdatedProfile.inf" -Value $NewSecurityProfile;

    $SystemOutput = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/import /cfg "{0}.inf" /db "{0}.sdb"', $UpdatedProfile));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to import security profile: {0}', $SystemOutput.Message));
        return;
    }

    $SystemOutput = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/configure /cfg "{0}.inf" /db "{0}.sdb"', $UpdatedProfile));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to configure security profile: {0}', $SystemOutput.Message));
        return;
    }

    Remove-Item $UpdatedProfile*;
}
