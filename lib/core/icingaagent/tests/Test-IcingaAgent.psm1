function Test-IcingaAgent()
{
    $IcingaAgentData     = Get-IcingaAgentInstallation;
    $AgentServicePresent = Get-IcingaWindowsServiceStatus -Service 'icinga2';
    if ($IcingaAgentData.Installed -And $AgentServicePresent.Present) {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent service is installed';
    } elseif ($IcingaAgentData.Installed -And $AgentServicePresent.Present -eq $FALSE) {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'Icinga Agent service is not installed';
    } elseif ($IcingaAgentData.Installed -eq $FALSE -And $AgentServicePresent.Present) {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'Icinga Agent service is still present, while Icinga Agent itself is not installed.';
    } elseif ($IcingaAgentData.Installed -eq $FALSE -And $AgentServicePresent.Present -eq $FALSE) {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent is not installed and service is not present.';

        return;
    }

    Test-IcingaAgentServicePermission | Out-Null;
    Test-IcingaAcl "$Env:ProgramData\icinga2\etc" -WriteOutput | Out-Null;
    Test-IcingaAcl "$Env:ProgramData\icinga2\var" -WriteOutput | Out-Null;
    Test-IcingaAcl (Get-IcingaCacheDir) -WriteOutput | Out-Null;
    Test-IcingaAcl (Get-IcingaPowerShellConfigDir) -WriteOutput | Out-Null;
    Test-IcingaAcl -Directory (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'certificate') -WriteOutput | Out-Null;
    Test-IcingaStateFile -WriteOutput | Out-Null;

    if ($IcingaAgentData.Installed) {
        Test-IcingaAgentConfig | Out-Null;
        if (Test-IcingaAgentFeatureEnabled -Feature 'debuglog') {
            Write-IcingaTestOutput -Severity 'Warning' -Message 'The debug log of the Icinga Agent is enabled. Please keep in mind to disable it once testing is done, as a huge amount of data is generated'
        } else {
            Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent debug log is disabled'
        }
    }
}
