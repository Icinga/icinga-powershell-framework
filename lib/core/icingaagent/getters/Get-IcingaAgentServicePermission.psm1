function Get-IcingaAgentServicePermission()
{
    $SystemPermissions = New-TemporaryFile;
    $SystemOutput      = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/export /cfg "{0}.inf"', $SystemPermissions));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to fetch system permission information: {0}', $SystemOutput.Message));
        return $null;
    }

    $SystemContent = Get-Content "$SystemPermissions.inf";

    Remove-Item $SystemPermissions*;

    return $SystemContent;
}
