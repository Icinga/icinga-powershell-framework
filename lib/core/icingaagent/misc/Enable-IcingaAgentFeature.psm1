function Enable-IcingaAgentFeature()
{
    param(
        [string]$Feature
    );

    if ([string]::IsNullOrEmpty($Feature)) {
        throw 'Please specify a valid feature';
    }

    if ((Test-IcingaAgentFeatureEnabled -Feature $Feature)) {
        Write-Host ([string]::Format('This feature is already enabled [{0}]', $Feature));
        return;
    }

    $Binary  = Get-IcingaAgentBinary;
    $Process = Start-IcingaProcess -Executable $Binary -Arguments ([string]::Format('feature enable {0}', $Feature));

    if ($Process.ExitCode -ne 0) {
        throw ([string]::Format('Failed to enable Icinga Feature: {0}', $Process.Message));
    }

    Write-Host ([string]::Format('Feature "{0}" was successfully enabled', $Feature));
}
