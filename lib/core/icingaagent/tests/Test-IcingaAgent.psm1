function Test-IcingaAgent()
{
    if (Get-Service 'icinga2' -ErrorAction SilentlyContinue) {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent service is installed';
        Test-IcingaAgentServicePermission | Out-Null;
        Test-IcingaAcl "$Env:ProgramData\icinga2\etc" -WriteOutput | Out-Null;
        Test-IcingaAcl "$Env:ProgramData\icinga2\var" -WriteOutput | Out-Null;
        Test-IcingaAcl (Get-IcingaCacheDir) -WriteOutput | Out-Null;
        Test-IcingaAgentConfig | Out-Null;
        if (Test-IcingaAgentFeatureEnabled -Feature 'debuglog') {
            Write-IcingaTestOutput -Severity 'Warning' -Message 'The debug log of the Icinga Agent is enabled. Please keep in mind to disable it once testing is done, as a huge amount of data is generated'
        } else {
            Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent debug log is disabled'
        }
    } else {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'Icinga Agent service is not installed';
    }
}
