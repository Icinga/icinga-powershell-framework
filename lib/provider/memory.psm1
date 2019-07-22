Import-Module $IncludeDir\provider\enums;

<##################################################################################################
################# Runspace "Show-Icinga{Memory}" ##################################################
##################################################################################################>
function Show-IcingaMemoryData ()
{

    $MEMInformation = Get-CimInstance Win32_PhysicalMemory;

    [hashtable]$MEMData = @{};

    foreach($memory in $MEMInformation) {
        $MEMData.Add(
            $memory.tag.trim("Physical Memory"), @{
                'Caption' = $memory.Name;
                'Description' = $memory.Description;
                'Name' = $memory.Name;
                'InstallDate' = $memory.InstallDate;
                'Status' = $memory.Status
                'CreationClassName'= $memory.CreationClassName
                'Manufacturer'= $memory.Manufacturer
                'Model'= $memory.Model
                'OtherIdentifyingInfo'= $memory.OtherIdentifyingInfo
                'PartNumber'= $memory.PartNumber
                'PoweredOn'= $memory.PoweredOn
                'SerialNumber'= $memory.SerialNumber
                'SKU'= $memory.SKU
                'Tag'= $memory.Tag
                'Version'= $memory.Version
                'HotSwappable'= $memory.HotSwappable
                'Removable'= $memory.Removable
                'Replaceable'= $memory.Replaceable
                'FormFactor'= $memory.FormFactor
                'BankLabel'= $memory.BankLabel
                'Capacity'= $memory.Capacity
                'DataWidth'= $memory.DataWidth
                'InterleavePosition'= $memory.InterleavePosition
                'MemoryType'= $memory.MemoryType
                'PositionInRow'= $memory.PositionInRow
                'Speed'= $memory.Speed
                'TotalWidth'= $memory.TotalWidth
                'Attributes'= $memory.Attributes
                'ConfiguredClockSpeed'= $memory.ConfiguredClockSpeed
                'ConfiguredVoltage'= $memory.ConfiguredVoltage
                'DeviceLocator'= $memory.DeviceLocator
                'InterleaveDataDepth'= $memory.InterleaveDataDepth
                'MaxVoltage'= $memory.MaxVoltage
                'MinVoltage'= $memory.MinVoltage
                'SMBIOSMemoryType'= $memory.SMBIOSMemoryType
                'TypeDetail'= $memory.TypeDetail
                'PSComputerName'= $memory.PSComputerName
            }
        );
    }    
    return $MEMData;
}
<##################################################################################################
################# Runspace "Get-Icinga{Memory}" ###################################################
##################################################################################################>
function Get-IcingaMemory ()
{
    <# Collects the most important Memory informations,
    e.g. name, version, manufacturer#>
    $MEMInformation = Get-CimInstance Win32_PhysicalMemory;
    
    [hashtable]$MEMData = @{};

    foreach($memory in $MEMInformation) {
        $MEMData.Add(
            $memory.tag.trim("Physical Memory"), @{
                'metadata' = @{
                    'Caption' = $memory.Name;
                    'Description'= $memory.Description;
                    'Manufacturer'= $memory.Manufacturer;
                    'Model'= $memory.Model;
                    'OtherIdentifyingInfo'= $memory.OtherIdentifyingInfo;
                    'PartNumber'= $memory.PartNumber;
                    'SerialNumber'= $memory.SerialNumber;
                    'Tag'= $memory.Tag;
                    'SMBIOSMemoryType'= $memory.SMBIOSMemoryType;
                    'DeviceLocator' = $memory.DeviceLocator;
                    'PositionInRow' = $memory.PositionInRow;
                    'Version' = $memory.Version;
                    'PoweredOn' = $memory.PoweredOn;
                    'Status' = $memory.Status;
                    'InstallDate' = $memory.InstallDate;
                    'BankLabel' = $memory.BankLabel;
                    'InterleaveDataDepth' = $memory.InterleaveDataDepth;
                    'Attributes' = $memory.Attributes;
                    'Replaceable' = $memory.Replaceable;
                    'Removable' = $memory.Removable;
                    'HotSwappable' = $memory.HotSwappable;
                    'FormFactor' = @{
                        'raw'   = $memory.FormFactor;
                        'value' = $ProviderEnums.MemoryFormFactor[[int]$memory.FormFactor];
                    };
                    'InterleavePosition' = @{
                        'raw'   = $memory.InterleavePosition;
                        'value' = $ProviderEnums.MemoryInterleavePosition[[int]$memory.InterleavePosition];
                    };
                    'MemoryType' = @{
                        'raw'   = $memory.MemoryType;
                        'value' = $ProviderEnums.MemoryMemoryType[[int]$memory.MemoryType];
                    };
                    'TypeDetail' = @{
                        'raw'   = $memory.TypeDetail;
                        'value' = $ProviderEnums.MemoryTypeDetail[[int]$memory.TypeDetail];
                    };
                };
                'specs' = @{
                    'MaxVoltage' = $memory.MaxVoltage;
                    'MinVoltage' = $memory.MinVoltage;
                    'ConfiguredVoltage' = $memory.ConfiguredVoltage;
                    'ConfiguredClockSpeed' = $memory.ConfiguredClockSpeed;
                    'TotalWidth' = $memory.TotalWidth;
                    'DataWidth' = $memory.DataWidth;
                    'Speed' = $memory.Speed;
                    'Capacity' = $memory.Capacity;
                }
            }
        );
    }
    
    return $MEMData;
}

function Get-IcingaMemoryInformation()
{
    param(
        [string]$Parameter
    );
    $MEMInformation = Get-CimInstance Win32_PhysicalMemory;
    [hashtable]$MEMData = @{};

    foreach ($memory in $MEMInformation) {
        $MEMData.Add($memory.tag.trim("Physical Memory"), $memory.$Parameter);
    }

    return $MEMData;
}
function Get-IcingaMemoryMaxVoltage()
{
    $MemoryMaxVoltage = Get-IcingaMemoryInformation -Parameter MaxVoltage;

    return @{'value' = $MemoryMaxVoltage; 'name' = 'MaxVoltage'};
}

function Get-IcingaMemoryMinVoltage()
{
    $MemoryMinVoltage = Get-IcingaMemoryInformation -Parameter MinVoltage;

    return @{'value' = $MemoryMinVoltage; 'name' = 'MinVoltage'};
}

function Get-IcingaMemoryConfiguredVoltage()
{
    $MemoryConfiguredVoltage = Get-IcingaMemoryInformation -Parameter ConfiguredVoltage;

    return @{'value' = $MemoryConfiguredVoltage; 'name' = 'ConfiguredVoltage'};
}

function Get-IcingaMemoryConfiguredClockSpeed()
{
    $MemoryConfiguredClockSpeed = Get-IcingaMemoryInformation -Parameter ConfiguredClockSpeed;

    return @{'value' = $MemoryConfiguredClockSpeed; 'name' = 'ConfiguredClockSpeed'};
}

function Get-IcingaMemoryTotalWidth()
{
    $MemoryTotalWidth = Get-IcingaMemoryInformation -Parameter TotalWidth;

    return @{'value' = $MemoryTotalWidth; 'name' = 'TotalWidth'};
}

function Get-IcingaMemoryDataWidth()
{
    $MemoryDataWidth = Get-IcingaMemoryInformation -Parameter DataWidth;

    return @{'value' = $MemoryDataWidth; 'name' = 'DataWidth'};
}

function Get-IcingaMemorySpeed()
{
    $MemorySpeed = Get-IcingaMemoryInformation -Parameter Speed;

    return @{'value' = $MemorySpeed; 'name' = 'Speed'};
}

function Get-IcingaMemoryCapacity()
{
    $MemoryCapacity = Get-IcingaMemoryInformation -Parameter Capacity;

    return @{'value' = $MemoryCapacity; 'name' = 'Capacity'};
}