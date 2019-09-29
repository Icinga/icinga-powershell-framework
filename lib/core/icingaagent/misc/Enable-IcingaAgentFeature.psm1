function Enable-IcingaAgentFeature()
{
    param(
        [string]$Feature
    );

    if ([string]::IsNullOrEmpty($Feature)) {
        throw 'Please specify a valid feature';
    }

    if ((Test-IcingaAgentFeatureEnabled -Feature $Feature)) {
        Write-Host 'This feature is already enabled.'
        return;
    }

    $Binary  = Get-IcingaAGentBinary;
    $Process = Start-IcingaProcess -Executable $Binary -Arguments ([string]::Format('feature enable {0}', $Feature));

    if ($Process.ExitCode -ne 0) {
        throw ([string]::Format('Failed to enable Icinga Feature: {0}', $Process.Message));
    }

    Write-Host ([string]::Format('Feature "{0}" was successfully enabled', $Feature));
}
