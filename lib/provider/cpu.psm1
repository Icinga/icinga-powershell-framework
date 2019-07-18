Import-Module $IncludeDir\provider\enums;

<##################################################################################################
################# Runspace "Show-Icinga{CPU}" #####################################################
##################################################################################################>
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

<##################################################################################################
################# Runspace "Get-Icinga{Memory}" ###################################################
##################################################################################################>
function Get-IcingaCPUs()
{
    <# Collects the most important CPU informations,
    e.g. name, version, manufacturer#>
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUData = @{};

    foreach ($id in $CPUInformation.DeviceID) {
        $id=$id.trim('CPU');

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
                    'NumberOfCores' = $CPUInformation.NumberOfCores;
                    'PartNumber' = $CPUInformation.PartNumber;
                    'Status' = $CPUInformation.Status;
                    'CPUStatus' = $CPUInformation.CpuStatus;
                    'Revision' = $CPUInformation.Revision;
                    'NumberOfLogicalProcessors' = $CPUInformation.NumberOfLogicalProcessors;
                    'Level'= $CPUInformation.Level;
                    'AddressWidth' = $CPUInformation.AddressWidth;
                    'Stepping' = $CPUInformation.Stepping;
                    'SocketDesignation' = $CPUInformation.SocketDesignation;
                    'Family' = @{
                        'raw'   = $CPUInformation.Family;
                        'value' = $ProviderEnums.CPUFamily[[int]$CPUInformation.Family];
                    };
                    'Architecture' = @{
                        'raw'   = $CPUInformation.Architecture;
                        'value' = $ProviderEnums.CPUArchitecture[[int]$CPUInformation.Architecture];
                    };
                    'ProcessorType' = @{
                        'raw'   = $CPUInformation.ProcessorType;
                        'value' = $ProviderEnums.CPUProcessorType[[int]$CPUInformation.ProcessorType];
                    };
                    'StatusInfo' = @{
                        'raw'   = $CPUInformation.StatusInfo;
                        'value' = $ProviderEnums.CPUStatusInfo[[int]$CPUInformation.StatusInfo];
                    };
                    'Availability' = @{
                        'raw' = $CPUInformation.Availability;
                        'value' = $ProviderEnums.CPUAvailability[[int]$CPUInformation.Availability];
                    };
                    'PowerManagementCapabilities' = @{
                        'raw' = $CPUInformation.PowerManagementCapabilities;
                        'value' = $ProviderEnums.CPUPowerManagementCapabilities[[int]$CPUInformation.PowerManagementCapabilities];
                    }
                };
                'errors' = @{
                    'LastErrorCode' = $CPUInformation.LastErrorCode;
                    'ErrorCleared' = $CPUInformation.ErrorCleared;
                    'ErrorDescription' = $CPUInformation.ErrorDescription;
                    'ConfigManagerErrorCode' = @{
                        'raw'   = [int]$CPUInformation.ConfigManagerErrorCode;
                        'value' = $ProviderEnums.CPUConfigManagerErrorCode.([int]$CPUInformation.ConfigManagerErrorCode);
                    }
                };
                'specs' = @{
                    'LoadPercentage' = $CPUInformation.LoadPercentage;
                    'CurrentVoltage' = $CPUInformation.CurrentVoltage;
                    'ThreadCount' = $CPUInformation.ThreadCount;
                    'L3CacheSize' = $CPUInformation.L3CacheSize;
                    'L2CacheSpeed' = $CPUInformation.L2CacheSpeed;
                    'L2CacheSize' = $CPUInformation.L2CacheSize;
                    'VoltageCaps' = $CPUInformation.VoltageCaps;
                    'CurrentClockSpeed' = $CPUInformation.CurrentClockSpeed;
                }
            }
        );
    }
    return $CPUData;
}

function Get-IcingaCPUInformation()
{
    <# Fetches the information for other more specific Get-IcingaCPU-functions
    e.g. Get-IcingaCPUThreadCount; Get-IcingaCPULoadPercentage.
    Can be used to fetch information regarding a value of your choice. #>
    param(
        [string]$Parameter
    );
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUData = @{};

    foreach ($id in $CPUInformation.DeviceID) {
        $CPUData.Add($id.trim('CPU'), $CPUInformation.$Parameter);
    }

    return $CPUData;
}

function Get-IcingaCPUInformationWithEnums()
{   <# Fetches the information of other more specific Get-IcingaCPU-functions, 
    which require a enums key-value pair to resolve their code
    e.g Get-IcingaCPUFamily, e.g. Get-IcingaCPUArchitecture#>
    param(
        [string]$Parameter
    );

    $CPUInformation = Get-CimInstance Win32_Processor;
    $Prefix = "CPU";
    
    [hashtable]$CPUData = @{};

    foreach ($id in $CPUInformation.DeviceID) {
        $id=$id.trim('CPU');
        $CPUData.Add(
            $id, @{
                'raw'   = $CPUInformation.$Parameter;
                'value' = $ProviderEnums."$Prefix$Parameter"[[int]$CPUInformation.$Parameter]
            }
        );
    }
    return $CPUData;
}

function Get-IcingaCPUErrors()
{
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUData = @{};

    foreach ($id in $CPUInformation.DeviceID) {
        $id=$id.trim('CPU');
        $CPUData.Add(
            $id, @{
                'errors' = @{
                    'LastErrorCode' = $CPUInformation.LastErrorCode;
                    'ErrorCleared' = $CPUInformation.ErrorCleared;
                    'ErrorDescription' = $CPUInformation.ErrorDescription;
                    'ConfigManagerErrorCode' = @{
                        'raw'   = [int]$CPUInformation.ConfigManagerErrorCode;
                        'value' = $ProviderEnums.CPUConfigManagerErrorCode.([int]$CPUInformation.ConfigManagerErrorCode);
                    }
                }
            }
        );
    }
    return $CPUData;
}

function Get-IcingaCPUArchitecture()
{
    $CPUArchitecture = Get-IcingaCPUInformationWithEnums -Parameter Architecture;

    return @{'value' = $CPUArchitecture; 'name' = 'Architecture'};
}

function Get-IcingaCPUProcessorType()
{
    $CPUProcessorType = Get-IcingaCPUInformationWithEnums -Parameter ProcessorType;

    return @{'value' = $CPUProcessorType; 'name' = 'ProcessorType'};
}

function Get-IcingaCPUStatusInfo()
{
    $CPUStatusInfo = Get-IcingaCPUInformationWithEnums -Parameter StatusInfo;

    return @{'value' = $CPUStatusInfo; 'name' = 'StatusInfo'};
}

function Get-IcingaCPUFamily()
{
    $CPUFamily = Get-IcingaCPUInformationWithEnums -Parameter Family;

    return @{'value' = $CPUFamily; 'name' = 'Family'};
}

function Get-IcingaCPUConfigManagerErrorCode()
{
    $CPUConfigManagerErrorCode = Get-IcingaCPUInformationWithEnums -Parameter ConfigManagerErrorCode;

    return @{'value' = $CPUConfigManagerErrorCode; 'name' = 'ConfigManagerErrorCode'};
}

function Get-IcingaCPUAvailability()
{
    $CPUAvailability = Get-IcingaCPUInformationWithEnums -Parameter Availability;

    return @{'value' = $CPUAvailability; 'name' = 'Availability'};
}

function Get-IcingaCPUPowerManagementCapabilities()
{
    $CPUPowerManagementCapabilities = Get-IcingaCPUInformationWithEnums -Parameter PowerManagementCapabilities;

    return @{'value' = $CPUPowerManagementCapabilities; 'name' = 'PowerManagementCapabilities'};
}

function Get-IcingaCPULoadPercentage()
{
    $CPULoadPercentage = Get-IcingaCPUInformation -Parameter LoadPercentage;

    return @{'value' = $CPULoadPercentage; 'name' = 'LoadPercentage'};
}

function Get-IcingaCPUCurrentVoltage()
{
    $CPUCurrentVoltage = Get-IcingaCPUInformation -Parameter CurrentVoltage;

    return @{'value' = $CPUCurrentVoltage; 'name' = 'CurrentVoltage'};
}

function Get-IcingaCPUThreadCount()
{
    $CPUThreadCount = Get-IcingaCPUInformation -Parameter ThreadCount;

    return @{'value' = $CPUThreadCount; 'name' = 'ThreadCount'};
}

function Get-IcingaCPUL3CacheSize()
{    
    $CPUL3CacheSize = Get-IcingaCPUInformation -Parameter L3CacheSize;

    return @{'value' = $CPUL3CacheSize; 'name' = 'L3CacheSize'};
}

function Get-IcingaCPUL2CacheSize()
{    
    $CPUL2CacheSize = Get-IcingaCPUInformation -Parameter L2CacheSize;

    return @{'value' = $CPUL2CacheSize; 'name' = 'L2CacheSize'};
}

function Get-IcingaCPUL2CacheSpeed()
{    
    $CPUL2CacheSpeed = Get-IcingaCPUInformation -Parameter L2CacheSpeed;

    return @{'value' = $CPUL2CacheSpeed; 'name' = 'L2CacheSpeed'};
}

function Get-IcingaCPUVoltageCaps()
{    
    $CPUVoltageCaps = Get-IcingaCPUInformation -Parameter VoltageCaps;

    return @{'value' = $CPUVoltageCaps; 'name' = 'VoltageCaps'};
}

function Get-IcingaCPUCurrentClockSpeed()
{    
    $CPUCurrentClockSpeed = Get-IcingaCPUInformation -Parameter CurrentClockSpeed;

    return @{'value' = $CPUCurrentClockSpeed; 'name' = 'CurrentClockSpeed'};
}

function Get-IcingaCPUNumberOfLogicalProcessors()
{
    $CPUNumberOfLogicalProcessors = Get-IcingaCPUInformation -Parameter NumberOfLogicalProcessors;

    return @{'value' = $CPUNumberOfLogicalProcessors; 'name' = 'NumberOfLogicalProcessors'};
}