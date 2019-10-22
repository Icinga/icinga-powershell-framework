function Show-IcingaRegisteredServiceChecks()
{
    $Services = Get-IcingaRegisteredServiceChecks;

    foreach ($service in $Services.Keys) {
        Write-Host ([string]::Format('Service Id: {0}', $service));
        Write-Host (
            $Services[$service] | Out-String
        );
    }
}
