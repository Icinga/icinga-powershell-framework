function Restart-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service $Service -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice ([string]::Format('Restarting service "{0}"', $Service));
        Restart-Service $Service;
    }
}
