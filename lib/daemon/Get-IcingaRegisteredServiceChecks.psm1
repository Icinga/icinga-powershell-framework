function Get-IcingaRegisteredServiceChecks()
{
    $Services = Get-IcingaPowerShellConfig -Path 'BackgroundDaemon.RegisteredServices';
    [hashtable]$Output = @{};

    foreach ($service in $Services.PSObject.Properties) {
        $Content = @{
            'Id'           = $service.Name;
            'CheckCommand' = $service.Value.CheckCommand;
            'Arguments'    = $service.Value.Arguments;
            'Interval'     = $service.Value.Interval;
            'TimeIndexes'  = $service.Value.TimeIndexes;
        };

        $Output.Add($service.Name, $Content);
    }

    return $Output;
}
