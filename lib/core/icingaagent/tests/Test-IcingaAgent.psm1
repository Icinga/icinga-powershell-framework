function Test-IcingaAgent()
{
    if (Get-Service 'icinga2' -ErrorAction SilentlyContinue) {
        Write-IcingaTestOutput -Severity 'PASSED' -Message 'Icinga Agent Service is installed';
        Test-IcingaAgentServicePermission | Out-Null;
        Test-IcingaAcl "$Env:ProgramData\icinga2\etc" -WriteOutput | Out-Null;
        Test-IcingaAcl "$Env:ProgramData\icinga2\var" -WriteOutput | Out-Null;
        Test-IcingaAcl (Get-IcingaCacheDir) -WriteOutput | Out-Null;
        Test-IcingaAgentConfig | Out-Null;
        if (Test-IcingaAgentFeatureEnabled -Feature 'debuglog') {
            Write-IcingaTestOutput -Severity 'WARNING' -Message 'The Debug-Log of the Icinga Agent is enabled. Please keep in mind to disable it once testing is done, as a huge amount of data is generated.'
        } else {
            Write-IcingaTestOutput -Severity 'PASSED' -Message 'Icinga Agent Debug-Log is disabled.'
        }
    } else {
        Write-IcingaTestOutput -Severity 'FAILED' -Message 'Icinga Agent Service is not installed';
    }
}
