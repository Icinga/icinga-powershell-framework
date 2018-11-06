param($Config = $null);
#
# Fetch the CPU Hardware informations
#

# Lets load some additional CPU informations, besides current performance counters
# It might be useful to get more details about the hardware itself
$CPUInformations = Get-CimInstance Win32_Processor;
[hashtable]$PhysicalCPUData = @{};

foreach ($cpu_properties in $CPUInformations) {
    $cpu_datails = @{};
    foreach($cpu_core in $cpu_properties.CimInstanceProperties) {
        $cpu_datails.Add($cpu_core.Name, $cpu_core.Value);
    }
    $PhysicalCPUData.Add($cpu_datails.DeviceID, $cpu_datails);
}

return $PhysicalCPUData;