<#
.SYNOPSIS
    Writes the Icinga Agent Event Log configuration.

.DESCRIPTION
    The Write-IcingaAgentEventLogConfig function is used to write the configuration for the Icinga Agent Event Log. It creates a configuration file with the specified severity level for the Windows Event Log Logger.

.PARAMETER Severity
    Specifies the severity level for the Windows Event Log Logger. Valid values are 'debug', 'notice', 'information', 'warning', and 'critical'. The default value is 'information'.

.EXAMPLE
    Write-IcingaAgentEventLogConfig -Severity 'warning'
    This example writes the Icinga Agent Event Log configuration with the severity level set to 'warning'.

.NOTES
    Please make sure to restart the Icinga Agent after applying any changes to the configuration.
#>

function Write-IcingaAgentEventLogConfig()
{
    param (
        [ValidateSet('debug', 'notice', 'information', 'warning', 'critical')]
        [string]$Severity = 'information'
    );

    $EventLogConf = New-Object System.Text.StringBuilder;

    $EventLogConf.AppendLine('/**') | Out-Null;
    $EventLogConf.AppendLine(' * The WindowsEventLogLogger type writes log information to the Windows Event Log.') | Out-Null;
    $EventLogConf.AppendLine(' */') | Out-Null;
    $EventLogConf.AppendLine('') | Out-Null;
    $EventLogConf.AppendLine('object WindowsEventLogLogger "windowseventlog" {') | Out-Null;
    $EventLogConf.AppendLine([string]::Format('    severity = "{0}"', $Severity)) | Out-Null;
    $EventLogConf.Append('}') | Out-Null;

    Write-IcingaFileSecure -File (Join-Path -Path (Get-IcingaAgentConfigDirectory) -ChildPath 'features-available\windowseventlog.conf') -Value $EventLogConf.ToString();
    Write-IcingaConsoleNotice 'Windows Eventlog configuration has been written successfully to use severity level: {0} - Please restart the Icinga Agent to apply this change' -Objects $Severity;
}
