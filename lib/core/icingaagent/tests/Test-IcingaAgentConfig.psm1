function Test-IcingaAgentConfig()
{
    param (
        [switch]$WriteStackTrace
    );

    $Binary       = Get-IcingaAgentBinary;
    $ConfigResult = Start-IcingaProcess -Executable $Binary -Arguments 'daemon -C';

    if ($ConfigResult.ExitCode -eq 0) {
        Write-IcingaTestOutput -Severity 'PASSED' -Message 'Icinga Agent configuration is valid';
        return $TRUE;
    } else {
        Write-IcingaTestOutput -Severity 'FAILED' -Message 'Icinga Agent configuration is containing errors. Run this command for getting a detailed error report: "Test-IcingaAgentConfig -WriteStackTrace | Out-Null"';
        if ($WriteStackTrace) {
            Write-Host $ConfigResult.Message;
        }
        return $FALSE;
    }
}
