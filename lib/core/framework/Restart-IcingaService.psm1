function Restart-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service $Service -ErrorAction SilentlyContinue) {
        Write-Host ([string]::Format('Restarting service "{0}"', $Service));
        Restart-Service $Service;
    }
}
