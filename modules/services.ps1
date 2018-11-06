param($Config = $null);

function ClassService()
{
    param($Config = $null);
    $services = Get-Service;

    [hashtable]$ServiceData = @{};

    $CachedServiceData = $Icinga2.Utils.Modules.GetCacheElement(
        $MyInvocation.MyCommand.Name,
        'ServiceData'
    );

    foreach ($service in $services) {
        [hashtable]$ServiceInfo = @{};

        $ServiceInfo.Add('display_name', $service.DisplayName);
        $ServiceInfo.Add('service_name', $service.ServiceName);
        $ServiceInfo.Add('can_pause_and_continue', $service.CanPauseAndContinue);
        $ServiceInfo.Add('can_shutdown', $service.CanShutdown);
        $ServiceInfo.Add('can_stop', $service.CanStop);
        $ServiceInfo.Add('service_handle', $service.ServiceHandle);
        $ServiceInfo.Add('status', $service.Status);
        $ServiceInfo.Add('service_type', $service.ServiceType);
        $ServiceInfo.Add('start_type', $service.StartType);
        $ServiceInfo.Add('site', $service.Site);
        $ServiceInfo.Add('container', $service.Container);

        [array]$DependentServices = $null;
        foreach ($dependency in $service.DependentServices) {
            if ($DependentServices -eq $null) { $DependentServices = @(); }
            $DependentServices += $dependency.Name;
        }
        $ServiceInfo.Add('dependent_services', $DependentServices);

        [array]$DependentServices = $null;
        foreach ($dependency in $service.ServicesDependedOn) {
            if ($DependentServices -eq $null) { $DependentServices = @(); }
            $DependentServices += $dependency.Name;
        }
        $ServiceInfo.Add('depends_on', $DependentServices);

        $ServiceData.Add($service.Name, $ServiceInfo);
    }

    $Icinga2.Utils.Modules.AddCacheElement(
        $MyInvocation.MyCommand.Name,
        'ServiceData',
        $ServiceData
    );

    return $Icinga2.Utils.Modules.GetHashtableDiff(
        $ServiceData.Clone(),
        $CachedServiceData.Clone(),
        @('service_name')
    );

    return $ServiceData;
}

return ClassService -Config $Config;