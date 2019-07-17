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

function Get-IcingaCPUs()
{
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUData = @{};

    foreach ($id in $CPUInformation.DeviceID) {
        $CPUData.Add(
            $id, @{
                'metadata' = @{
                    'Name' = $CPUInformation.Name;
                    'DeviceID' = $CPUInformation.DeviceID;
                    'ProcessorID' = $CPUInformation.ProcessorId;
                    'UniqueID' = $CPUInformation.UniqueId;
                    'Description' = $CPUInformation.Description;
                    'OtherFamilyDescription' = $CPUInformation.OtherFamilyDescription;
                    'Caption' = $CPUInformation.Caption;
                    'Version' = $CPUInformation.Version;
                    'SerialNumber' = $CPUInformation.SerialNumber;
                    'Manufacturer' = $CPUInformation.Manufacturer;
                    'Number of Cores' = $CPUInformation.NumberOfCores;
                    'Family' = $CPUFamily.Family;
                    'Architecture' = $CPUArchitecture.Architecture;
                    'ProcessorType' = $CPUProcessorType.ProcessorType;
                    'StatusInfo' = $CPUStatusInfo.StatusInfo;
                    'Status' = $CPUInformation.Status;
                    'CPUStatus' = $CPUInformation.CpuStatus;
                    'NumberOfLogicalProcessors' = $CPUStatusInfo.NumberOfLogicalProcessors;
                    'Level'= $CPUInformation.Level;
                    'Availability' = $CPUAvailability.Availability;

                };
                'errors' = @{
                    'LastErrorCode' = $CPUInformation.LastErrorCode;
                    'ErrorCleared' = $CPUInformation.ErrorCleared;
                    'ErrorDescription' = $CPUInformation.ErrorDescription;
                    'ConfigManagerErrorCode' = $CPUConfigManagerErrorCode.ConfigManagerErrorCode;
                };
                'perfdata' = @{
                    'LoadPercentage' = $CPUInformation.LoadPercentage;
                    'CurrentVoltage' = $CPUInformation.CurrentVoltage;
                    'ThreadCount' = $CPUInformation.ThreadCount;
                }
            }
        );    
    }
    return $CPUData;
}


function Get-IcingaCPUArchitecture()
{

    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUArchitecture = @{};

    foreach ($id in $CPUInformation.Architecture) {
        $CPUArchitecture.Add([int]$id, $ProviderEnums.CPUArchitecture.([int]$id));
    }
        return @{'value' = $CPUArchitecture; 'name' = 'Architecture'};
}

function Get-IcingaCPUProcessorType()
{
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUProcessorType = @{};

    foreach ($id in $CPUInformation.ProcessorType) {
        $CPUProcessorType.Add([int]$id, $ProviderEnums.CPUProcessorType.([int]$id));
    }
        return @{'value' = $CPUProcessorType; 'name' = 'ProcessorType'};
}

function Get-IcingaCPUStatusInfo()
{
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUStatusInfo = @{};

    foreach ($id in $CPUInformation.StatusInfo) {
        $CPUStatusInfo.Add([int]$id, $ProviderEnums.CPUStatusInfo.([int]$id));
    }
        return @{'value' = $CPUStatusInfo; 'name' = 'StatusInfo'};
}

function Get-IcingaCPUFamily()
{
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUFamily = @{};

    foreach ($id in $CPUInformation.Family) {
        $CPUFamily.Add([int]$id, $ProviderEnums.CPUFamily.([int]$id));
    }
        return @{'value' = $CPUFamily; 'name' = 'Family'};
}

function Get-IcingaCPUConfigManagerErrorCode()
{
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUConfigManagerErrorCode = @{};

    foreach ($id in $CPUInformation.ConfigManagerErrorCode) {
        $CPUConfigManagerErrorCode.Add([int]$id, $ProviderEnums.CPUConfigManagerErrorCode.([int]$id));
    }
        return @{'value' = $CPUConfigManagerErrorCode; 'name' = 'ConfigManagerErrorCode'};
}

function Get-IcingaCPUAvailability()
{
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUAvailability = @{};
    
    foreach ($id in $CPUInformation.Availability) {
        $CPUAvailability.Add([int]$id, $ProviderEnums.CPUAvailability.([int]$id));
    }

        return @{'value' = $CPUAvailability; 'name' = 'Availability'};
}