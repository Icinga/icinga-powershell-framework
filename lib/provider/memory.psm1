Import-Module $IncludeDir\provider\enums;

<##################################################################################################
################# Runspace "Show-Icinga{Memory}" ##################################################
##################################################################################################>
function Show-IcingaMemoryData ()
{

    $MEMInformation = Get-CimInstance Win32_PhysicalMemory;

    [hashtable]$MEMData = @{};

    foreach($id in $MEMInformation) {
        $MEMData.Add(
            $id.tag.trim("Physical Memory"), @{
                'Caption' = $id.Name;
                'Description' = $id.Description;
                'Name' = $id.Name;
                'InstallDate' = $id.InstallDate;
                'Status' = $id.Status
                'CreationClassName'= $id.CreationClassName
                'Manufacturer'= $id.Manufacturer
                'Model'= $id.Model
                'OtherIdentifyingInfo'= $id.OtherIdentifyingInfo
                'PartNumber'= $id.PartNumber
                'PoweredOn'= $id.PoweredOn
                'SerialNumber'= $id.SerialNumber
                'SKU'= $id.SKU
                'Tag'= $id.Tag
                'Version'= $id.Version
                'HotSwappable'= $id.HotSwappable
                'Removable'= $id.Removable
                'Replaceable'= $id.Replaceable
                'FormFactor'= $id.FormFactor
                'BankLabel'= $id.BankLabel
                'Capacity'= $id.Capacity
                'DataWidth'= $id.DataWidth
                'InterleavePosition'= $id.InterleavePosition
                'MemoryType'= $id.MemoryType
                'PositionInRow'= $id.PositionInRow
                'Speed'= $id.Speed
                'TotalWidth'= $id.TotalWidth
                'Attributes'= $id.Attributes
                'ConfiguredClockSpeed'= $id.ConfiguredClockSpeed
                'ConfiguredVoltage'= $id.ConfiguredVoltage
                'DeviceLocator'= $id.DeviceLocator
                'InterleaveDataDepth'= $id.InterleaveDataDepth
                'MaxVoltage'= $id.MaxVoltage
                'MinVoltage'= $id.MinVoltage
                'SMBIOSMemoryType'= $id.SMBIOSMemoryType
                'TypeDetail'= $id.TypeDetail
                'PSComputerName'= $id.PSComputerName
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

    foreach($id in $MEMInformation) {
        $MEMData.Add(
            $id.tag.trim("Physical Memory"), @{
                'metadata' = @{
                    'Caption' = $id.Name;
                    'Description'= $id.Description;
                    'Manufacturer'= $id.Manufacturer;
                    'Model'= $id.Model;
                    'OtherIdentifyingInfo'= $id.OtherIdentifyingInfo;
                    'PartNumber'= $id.PartNumber;
                    'SerialNumber'= $id.SerialNumber;
                    'Tag'= $id.Tag;
                    'SMBIOSMemoryType'= $id.SMBIOSMemoryType;
                    'DeviceLocator' = $id.DeviceLocator;
                    'PositionInRow' = $id.PositionInRow;
                    'Version' = $id.Version;
                    'PoweredOn' = $id.PoweredOn;
                    'Status' = $id.Status;
                    'InstallDate' = $id.InstallDate;
                    'BankLabel' = $id.BankLabel;
                    'InterleaveDataDepth' = $id.InterleaveDataDepth;
                    'Attributes' = $id.Attributes;
                    'Replaceable' = $id.Replaceable;
                    'Removable' = $id.Removable;
                    'HotSwappable' = $id.HotSwappable;
                    'FormFactor' = @{
                        'raw'   = $id.FormFactor;
                        'value' = $ProviderEnums.MemoryFormFactor[[int]$id.FormFactor];
                    };
                    'InterleavePosition' = @{
                        'raw'   = $id.InterleavePosition;
                        'value' = $ProviderEnums.MemoryInterleavePosition[[int]$id.InterleavePosition];
                    };
                    'MemoryType' = @{
                        'raw'   = $id.MemoryType;
                        'value' = $ProviderEnums.MemoryMemoryType[[int]$id.MemoryType];
                    };
                    'TypeDetail' = @{
                        'raw'   = $id.TypeDetail;
                        'value' = $ProviderEnums.MemoryTypeDetail[[int]$id.TypeDetail];
                    };
                };
                'specs' = @{
                    'MaxVoltage' = $id.MaxVoltage;
                    'MinVoltage' = $id.MinVoltage;
                    'ConfiguredVoltage' = $id.ConfiguredVoltage;
                    'ConfiguredClockSpeed' = $id.ConfiguredClockSpeed;
                    'TotalWidth' = $id.TotalWidth;
                    'DataWidth' = $id.DataWidth;
                    'Speed' = $id.Speed;
                    'Capacity' = $id.Capacity;
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

    foreach ($id in $MEMInformation) {
        $MEMData.Add($id.tag.trim("Physical Memory"), $id.$Parameter);
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