Import-IcingaLib provider\enums;

function Get-IcingaDiskInformation()
{
    <# Fetches the information for other more specific Get-IcingaDisk-functions
    e.g. Get-IcingaDiskModel; Get-IcingaDiskManufacturer.
    Can be used to fetch information regarding a value of your choice. #>
    param(
        # The value to fetch from Win32_DiskDrive
        [string]$Parameter
    );
    $DiskInformation = Get-CimInstance Win32_DiskDrive;
    [hashtable]$DiskData = @{};

    foreach ($disk in $DiskInformation) {
        $DiskData.Add($disk.DeviceID.trimstart(".\PHYSICALDRVE"), $disk.$Parameter);
    }

    return $DiskData;
}
function Get-IcingaDiskPartitions()
{
    param(
        $Disk
    );
    <# Fetches all the most important informations regarding partitions
    e.g. physical disk; partition, size
    , also collects partition information for Get-IcingaDisks #>
    $LogicalDiskInfo = Get-WmiObject Win32_LogicalDiskToPartition;
    [hashtable]$PartitionDiskByDriveLetter = @{};

    foreach ($item in $LogicalDiskInfo) {
        [string]$driveLetter = $item.Dependent.SubString(
            $item.Dependent.LastIndexOf('=') + 1,
            $item.Dependent.Length - $item.Dependent.LastIndexOf('=') - 1
        );
        $driveLetter = $driveLetter.Replace('"', '').trim(':');

        [string]$diskPartition = $item.Antecedent.SubString(
            $item.Antecedent.LastIndexOf('=') + 1,
            $item.Antecedent.Length - $item.Antecedent.LastIndexOf('=') - 1
        )
        $diskPartition = $diskPartition.Replace('"', '');
        $diskDisk,$diskPartition = $diskPartition.split(',');
        
        $diskPartition = $diskPartition.trim("Partition #");
        $diskDisk = $diskDisk.trim("Disk #");

        If ([string]::IsNullOrEmpty($Disk) -eq $FALSE) {
            If ([int]$Disk -ne [int]$diskDisk) {
                continue;
            } 
        }
        
        $DiskArray   = New-IcingaPerformanceCounterStructure -CounterCategory 'LogicalDisk' -PerformanceCounterHash (New-IcingaPerformanceCounterArray @('\LogicalDisk(*)\% free space'));

        $diskPartitionSize = Get-Partition -DriveLetter $driveLetter;

        $PartitionDiskByDriveLetter.Add(
            $driveLetter,
            @{
                'Disk' = $diskDisk;
                'Partition' = $diskPartition;
                'Size' = $diskPartitionSize.Size;
                'Free Space' = $DiskArray.Item([string]::Format('{0}:', $driveLetter))."% free space".value;
            }
        );
    }
        return $PartitionDiskByDriveLetter;
}

function Get-IcingaDiskCapabilities 
{
    $DiskInformation = Get-CimInstance Win32_DiskDrive;
    [hashtable]$DiskCapabilities = @{};

    foreach ($capabilities in $DiskInformation.Capabilities) {
        $DiskCapabilities.Add([int]$capabilities, $ProviderEnums.DiskCapabilities.([int]$capabilities));
    }
        return @{'value' = $DiskCapabilities; 'name' = 'Capabilities'};

}
function Get-IcingaDiskSize
{
    $DiskSize = Get-IcingaDiskInformation -Parameter Size;

    return @{'value' = $DiskSize; 'name' = 'Size'};
}

function Get-IcingaDiskCaption
{
    $DiskCaption = Get-IcingaDiskInformation -Parameter Caption;

    return @{'value' = $DiskCaption; 'name' = 'Caption'};
}

function Get-IcingaDiskModel
{
    $DiskModel = Get-IcingaDiskInformation -Parameter Model;
    return @{'value' = $DiskModel; 'name' = 'Model'};
}

function Get-IcingaDiskManufacturer
{
    $DiskManufacturer = Get-IcingaDiskInformation -Parameter Manufacturer;
    return @{'value' = $DiskManufacturer; 'name' = 'Manufacturer'};
}

function Get-IcingaDiskTotalCylinders
{
    $DiskTotalCylinders = Get-IcingaDiskInformation -Parameter TotalCylinders;
    return @{'value' = $DiskTotalCylinders; 'name' = 'TotalCylinders'};
}

function Get-IcingaDiskTotalSectors
{
    $DiskTotalSectors = Get-IcingaDiskInformation -Parameter TotalSectors;
    return @{'value' = $DiskTotalSectors; 'name' = 'TotalSectors'};
}

function Get-IcingaDisks {
    <# Collects all the most important Disk-Informations,
    e.g. size, model, sectors, cylinders
    Is dependent on Get-IcingaDiskPartitions#>
    $DiskInformation = Get-CimInstance Win32_DiskDrive;
    [hashtable]$DiskData = @{};

    foreach ($disk in $DiskInformation) {
        $diskID = $disk.DeviceID.trimstart(".\PHYSICALDRVE");
        $DiskData.Add(
            $diskID, @{
                'metadata' = @{
                    'Size' = $disk.Size;
                    'Model' = $disk.Model;
                    'Name' = $disk.Name.trim('.\');
                    'Manufacturer' = $disk.Manufacturer;
                    'Cylinder' = $disk.TotalCylinders;
                    'Sectors' = $disk.TotalSectors
                };
                'partitions' = (Get-IcingaDiskPartitions -Disk $diskID);
            }
        );    
    }

    return $DiskData;
}