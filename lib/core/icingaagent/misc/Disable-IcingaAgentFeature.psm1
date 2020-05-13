function Disable-IcingaAgentFeature()
{
    param(
        [string]$Feature
    );

    if ([string]::IsNullOrEmpty($Feature)) {
        throw 'Please specify a valid feature';
    }

    if ((Test-IcingaAgentFeatureEnabled -Feature $Feature) -eq $FALSE) {
        Write-IcingaConsoleWarning ([string]::Format('This feature is already disabled [{0}]', $Feature));
        return;
    }

    $Binary  = Get-IcingaAGentBinary;
    $Process = Start-IcingaProcess -Executable $Binary -Arguments ([string]::Format('feature disable {0}', $Feature));

    if ($Process.ExitCode -ne 0) {
        throw ([string]::Format('Failed to disable Icinga Feature: {0}', $Process.Message));
    }

    Write-IcingaConsoleNotice ([string]::Format('Feature "{0}" was successfully disabled', $Feature));
}
