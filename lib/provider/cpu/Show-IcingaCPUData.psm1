function Show-IcingaCPUData()
{

$CPUInformation = Get-CimInstance Win32_Processor;
[hashtable]$PhysicalCPUData = @{};

foreach ($cpu_properties in $CPUInformation) {
    $cpu_datails = @{};
    foreach($cpu_core in $cpu_properties.CimInstanceProperties) {
        $cpu_datails.Add($cpu_core.Name, $cpu_core.Value);
    }
    $PhysicalCPUData.Add($cpu_datails.DeviceID, $cpu_datails);
}

return $PhysicalCPUData;
}