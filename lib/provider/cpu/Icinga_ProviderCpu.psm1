Import-IcingaLib provider\enums;
function Get-IcingaCPUs()
{
    <# Collects the most important CPU informations,
    e.g. name, version, manufacturer#>
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUData = @{};

    foreach ($cpu in $CPUInformation) {

        $CPUData.Add(
            $cpu.DeviceID.trim('CPU'), @{
                'metadata' = @{
                    'Name' = $cpu.Name;
                    'DeviceID' = $cpu.DeviceID;
                    'ProcessorID' = $cpu.ProcessorId;
                    'UniqueID' = $cpu.UniqueId;
                    'Description' = $cpu.Description;
                    'OtherFamilyDescription' = $cpu.OtherFamilyDescription;
                    'Caption' = $cpu.Caption;
                    'Version' = $cpu.Version;
                    'SerialNumber' = $cpu.SerialNumber;
                    'Manufacturer' = $cpu.Manufacturer;
                    'NumberOfCores' = $cpu.NumberOfCores;
                    'PartNumber' = $cpu.PartNumber;
                    'Status' = $cpu.Status;
                    'CPUStatus' = $cpu.CpuStatus;
                    'Revision' = $cpu.Revision;
                    'NumberOfLogicalProcessors' = $cpu.NumberOfLogicalProcessors;
                    'Level'= $cpu.Level;
                    'AddressWidth' = $cpu.AddressWidth;
                    'Stepping' = $cpu.Stepping;
                    'SocketDesignation' = $cpu.SocketDesignation;
                    'Family' = @{
                        'raw'   = $cpu.Family;
                        'value' = $ProviderEnums.CPUFamily[[int]$cpu.Family];
                    };
                    'Architecture' = @{
                        'raw'   = $cpu.Architecture;
                        'value' = $ProviderEnums.CPUArchitecture[[int]$cpu.Architecture];
                    };
                    'ProcessorType' = @{
                        'raw'   = $cpu.ProcessorType;
                        'value' = $ProviderEnums.CPUProcessorType[[int]$cpu.ProcessorType];
                    };
                    'StatusInfo' = @{
                        'raw'   = $cpu.StatusInfo;
                        'value' = $ProviderEnums.CPUStatusInfo[[int]$cpu.StatusInfo];
                    };
                    'Availability' = @{
                        'raw' = $cpu.Availability;
                        'value' = $ProviderEnums.CPUAvailability[[int]$cpu.Availability];
                    };
                    'PowerManagementCapabilities' = @{
                        'raw' = $cpu.PowerManagementCapabilities;
                        'value' = $ProviderEnums.CPUPowerManagementCapabilities[[int]$cpu.PowerManagementCapabilities];
                    }
                };
                'errors' = @{
                    'LastErrorCode' = $cpu.LastErrorCode;
                    'ErrorCleared' = $cpu.ErrorCleared;
                    'ErrorDescription' = $cpu.ErrorDescription;
                    'ConfigManagerErrorCode' = @{
                        'raw'   = [int]$cpu.ConfigManagerErrorCode;
                        'value' = $ProviderEnums.CPUConfigManagerErrorCode.([int]$cpu.ConfigManagerErrorCode);
                    }
                };
                'specs' = @{
                    'LoadPercentage' = $cpu.LoadPercentage;
                    'CurrentVoltage' = $cpu.CurrentVoltage;
                    'ThreadCount' = $cpu.ThreadCount;
                    'L3CacheSize' = $cpu.L3CacheSize;
                    'L2CacheSpeed' = $cpu.L2CacheSpeed;
                    'L2CacheSize' = $cpu.L2CacheSize;
                    'VoltageCaps' = $cpu.VoltageCaps;
                    'CurrentClockSpeed' = $cpu.CurrentClockSpeed;
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

    foreach ($cpu in $CPUInformation) {
        $CPUData.Add($cpu.DeviceID.trim('CPU'), $cpu.$Parameter);
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

    foreach ($cpu in $CPUInformation) {
        $CPUData.Add(
            $cpu.DeviceID.trim('CPU'), @{
                'raw'   = $cpu.$Parameter;
                'value' = $ProviderEnums."$Prefix$Parameter"[[int]$cpu.$Parameter]
            }
        );
    }
    return $CPUData;
}

function Get-IcingaCPUErrors()
{
    $CPUInformation = Get-CimInstance Win32_Processor;
    [hashtable]$CPUData = @{};

    foreach ($cpu in $CPUInformation) {
        $CPUData.Add(
            $cpu.trim('CPU'), @{
                'errors' = @{
                    'LastErrorCode' = $cpu.LastErrorCode;
                    'ErrorCleared' = $cpu.ErrorCleared;
                    'ErrorDescription' = $cpu.ErrorDescription;
                    'ConfigManagerErrorCode' = @{
                        'raw'   = [int]$cpu.ConfigManagerErrorCode;
                        'value' = $ProviderEnums.CPUConfigManagerErrorCode.([int]$cpu.ConfigManagerErrorCode);
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

function Get-IcingaCPUCount()
{
    <# Compares whether NumberofLogicalCores, NumberofCores or Threadcount across all CPUs is the highest,
    this function is used in provider/memory/Icinga_ProviderMemory.psm1#>
    $CPUInformation = Get-CimInstance Win32_Processor;

    foreach ($cpu in $CPUInformation) {
        $NumberOfCoresValue += $cpu.NumberOfCores;
        $NumberOfLogicalProcessorsValue += $cpu.NumberOfLogicalProcessors;
        $ThreadCountValue += $cpu.ThreadCount;
    }

    If (($NumberOfCoresValue -ge $NumberOfLogicalProcessorsValue) -and ($NumberOfCoresValue -ge $ThreadCountValue)) {
        return $NumberOfCoresValue;
    } elseif ($NumberOfLogicalProcessorsValue -ge $ThreadCountValue) {
        return $NumberOfLogicalProcessorsValue;
    }
    return $ThreadCountValue;
}