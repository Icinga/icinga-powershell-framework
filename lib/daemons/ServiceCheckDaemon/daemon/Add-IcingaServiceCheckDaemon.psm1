function Add-IcingaServiceCheckDaemon()
{
    Add-IcingaThreadPool -Name 'ServiceCheckPool' -MaxInstances 100;

    [hashtable]$KnownChecks = @{ };

    $Global:Icinga.Public.Daemons.Add(
        'ServiceCheck',
        @{
            'PerformanceDataCache' = @{ }
        }
    );

    while ($TRUE) {

        # Load the configuration file to be aware of service check changes
        $RegisteredServices = Get-IcingaRegisteredServiceChecks;

        # Debugging message
        Write-IcingaDebugMessage 'Found these service checks to load within service check daemon: {0}' -Objects ($RegisteredServices.Keys | Out-String);

        # Loop all found background services and create a new thread for each check
        foreach ($service in $RegisteredServices.Keys) {
            [string]$ThreadName = [string]::Format('Start-IcingaServiceCheckTask::Add-IcingaServiceCheckTask::{0}::0', $service);

            # In case the check is already being executed, continue
            if ((Test-IcingaThread -Thread $ThreadName)) {
                continue;
            }

            # Get all possible arguments for this check
            [hashtable]$ServiceArgs = @{ };

            if ($null -ne $RegisteredServices[$service].Arguments) {
                foreach ($property in $RegisteredServices[$service].Arguments.PSObject.Properties) {
                    if ($ServiceArgs.ContainsKey($property.Name)) {
                        continue;
                    }

                    $ServiceArgs.Add($property.Name, $property.Value)
                }
            }

            # Add the check to our cache, ensuring that we are aware of modifications during runtime
            if ($KnownChecks.ContainsKey($service) -eq $FALSE) {
                $KnownChecks.Add($service, $TRUE);
            } else {
                $KnownChecks[$service] = $TRUE;
            }

            # Start a new thread for executing the check
            Start-IcingaServiceCheckTask `
                -CheckId $service `
                -CheckCommand $RegisteredServices[$service].CheckCommand `
                -Arguments $ServiceArgs `
                -Interval $RegisteredServices[$service].Interval `
                -TimeIndexes $RegisteredServices[$service].TimeIndexes;
        }

        # Cleanup
        [array]$KnownCheckIds = $KnownChecks.Keys;

        foreach ($entry in $KnownCheckIds) {
            if ($RegisteredServices.ContainsKey($entry)) {
                continue;
            }

            $KnownChecks[$entry] = $FALSE;
        }

        foreach ($entry in $KnownCheckIds) {
            if ($KnownChecks[$entry] -eq $FALSE) {
                $KnownChecks.Remove($entry);

                [string]$ThreadName = [string]::Format('Start-IcingaServiceCheckTask::Add-IcingaServiceCheckTask::{0}::0', $entry);

                Remove-IcingaThread -Thread $ThreadName;
            }
        }

        # Force Icinga for Windows Garbage Collection
        Optimize-IcingaForWindowsMemory -SmartGC;

        Start-Sleep -Seconds 10;
    }
}
