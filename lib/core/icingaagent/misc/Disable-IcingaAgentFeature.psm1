function Disable-IcingaAgentFeature()
{
    param(
        [string]$Feature
    );

    if ([string]::IsNullOrEmpty($Feature)) {
        throw 'Please specify a valid feature';
    }

    if ((Test-IcingaAgentFeatureEnabled -Feature $Feature) -eq $FALSE) {
        Write-Host 'This feature is already disabled.'
        return;
    }

    $Binary  = Get-IcingaAGentBinary;
    $Process = Start-IcingaProcess -Executable $Binary -Arguments ([string]::Format('feature disable {0}', $Feature));

    if ($Process.ExitCode -ne 0) {
        throw ([string]::Format('Failed to disable Icinga Feature: {0}', $Process.Message));
    }

    Write-Host ([string]::Format('Feature "{0}" was successfully disabled', $Feature));
}
