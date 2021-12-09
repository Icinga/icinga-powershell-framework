function Show-IcingaRegisteredServiceChecks()
{
    $Services = Get-IcingaRegisteredServiceChecks;

    foreach ($service in $Services.Keys) {
        Write-IcingaConsoleNotice ([string]::Format('Service Id: {0}', $service));
        Write-IcingaConsoleNotice (
            $Services[$service] | Out-String
        );
    }
}
