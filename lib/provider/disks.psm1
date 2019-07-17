function Show-IcingaDiskFullData {

    $DisksInformations = Get-CimInstance Win32_DiskDrive;

    [hashtable]$PhysicalDiskData = @{};
    
    foreach ($disk_properties in $DisksInformations) {
        $disk_datails = @{};
        foreach($disk in $disk_properties.CimInstanceProperties) {
            $disk_datails.Add($disk.Name, $disk.Value);
        }
        $disk_datails.Add('DriveReference', @());
        $PhysicalDiskData.Add($disk_datails.DeviceID, $disk_datails);
    }
    
    $DiskPartitionInfo = Get-WmiObject Win32_DiskDriveToDiskPartition;
    
    [hashtable]$MapDiskPartitionToLogicalDisk = @{};
    
    foreach ($item in $DiskPartitionInfo) {
        [string]$diskPartition = $item.Dependent.SubString(
            $item.Dependent.LastIndexOf('=') + 1,
            $item.Dependent.Length - $item.Dependent.LastIndexOf('=') - 1
        );
        $diskPartition = $diskPartition.Replace('"', '');
    
        [string]$physicalDrive = $item.Antecedent.SubString(
            $item.Antecedent.LastIndexOf('\') + 1,
            $item.Antecedent.Length - $item.Antecedent.LastIndexOf('\') - 1
        )
        $physicalDrive = $physicalDrive.Replace('"', '');
    
        $MapDiskPartitionToLogicalDisk.Add($diskPartition, $physicalDrive);
    }
    
    $LogicalDiskInfo = Get-WmiObject Win32_LogicalDiskToPartition;
    
    foreach ($item in $LogicalDiskInfo) {
        [string]$driveLetter = $item.Dependent.SubString(
            $item.Dependent.LastIndexOf('=') + 1,
            $item.Dependent.Length - $item.Dependent.LastIndexOf('=') - 1
        );
        $driveLetter = $driveLetter.Replace('"', '');
    
        [string]$diskPartition = $item.Antecedent.SubString(
            $item.Antecedent.LastIndexOf('=') + 1,
            $item.Antecedent.Length - $item.Antecedent.LastIndexOf('=') - 1
        )
        $diskPartition = $diskPartition.Replace('"', '');
    
        if ($MapDiskPartitionToLogicalDisk.ContainsKey($diskPartition)) {
            foreach ($disk in $PhysicalDiskData.Keys) {
                [string]$DiskId = $disk.SubString(
                    $disk.LastIndexOf('\') + 1,
                    $disk.Length - $disk.LastIndexOf('\') - 1
                );
    
                if ($DiskId.ToLower() -eq $MapDiskPartitionToLogicalDisk[$diskPartition].ToLower()) {
                    $PhysicalDiskData[$disk]['DriveReference'] += $driveLetter;
                }
            }
        }
    }
    
    return $PhysicalDiskData;

}

function Show-IcingaDiskPhysical()
{
    $DisksInformations = Get-CimInstance Win32_DiskDrive;

    [hashtable]$PhysicalDiskData = @{};

    foreach ($disk_properties in $DisksInformations) {
        $disk_datails = @{};
        foreach($disk in $disk_properties.CimInstanceProperties) {
            $disk_datails.Add($disk.Name, $disk.Value);
        }
        $disk_datails.Add('DriveReference', @());
        $PhysicalDiskData.Add($disk_datails.DeviceID, $disk_datails);
    }

    return $PhysicalDiskData;
}

function Get-IcingaDiskInformation()
{
    param(
        # The value to fetch from Win32_DiskDrive
        [string]$Parameter
    );
    $DiskInformation = Get-CimInstance Win32_DiskDrive;
    [hashtable]$DiskData = @{};

    foreach ($id in $DiskInformation.DeviceID) {    
        $id = $id.trimstart(".\PHYSICALDRVE");
        $DiskData.Add($id.trim(), $DiskInformation.$Parameter);
    }

    return $DiskData;
}
function Get-IcingaDiskPartitions()
{
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
        $diskPartitionSize = Get-Partition -DriveLetter $driveLetter;
        $PartitionDiskByDriveLetter.Add(
            $driveLetter,
            @{
                'Disk' = $diskDisk;
                'Partition' = $diskPartition;
                'Size' = $diskPartitionSize.Size;
            }
        );
    }
        return $PartitionDiskByDriveLetter;
}

#Code-Snippen that still exists for LordHepipud's amusement
function Get-IcingaDiskPartitionSize()
{
    param([switch]$sorted);

    [hashtable]$PartitionSizeByDriveLetter = @{};

    # Should be dependent on the driveLetters returned in: "Show-IcingaDiskFullData"
    for ($test = 0; $test -lt 26; $test++)
    {
        $DiskDriveLetter = ([char](65 + $test))
        $PartitionSize = (Get-Partition -DriveLetter $DiskDriveLetter -ErrorAction 'silentlycontinue').Size;
        if ($null -eq $PartitionSize)
        {
            $PartitionSize = "0";
        }
        $PartitionSizeByDriveLetter.Add("$DiskDriveLetter", $PartitionSize);
    }

    $output = $PartitionSizeByDriveLetter;

    if ($sorted) {
        $output = $PartitionSizeByDriveLetter.GetEnumerator() | Sort-Object name;
    }

    return @{'value' = $output; 'name' = 'Size'};
}
function Get-IcingaDiskCapabilities 
{
    $DiskInformation = Get-CimInstance Win32_DiskDrive;
    [hashtable]$DiskCapabilities = @{};

    foreach ($id in $DiskInformation.Capabilities) {
        $DiskCapabilities.Add([int]$id, $ProviderEnums.Capabilities.([int]$id));
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
    
    $DiskInformation = Get-CimInstance Win32_DiskDrive;
    $diskPartitionInformation = Get-IcingaDiskPartitions;
    [hashtable]$DiskData = @{};

    foreach ($id in $DiskInformation.DeviceID) {    
        [int]$id = $id.trimstart(".\PHYSICALDRVE");

        $DiskData.Add(
            $id, @{
                'metadata' = @{
                    'Size' = $DiskInformation.Size;
                    'Model' = $DiskInformation.Model;
                    'Name' = $DiskInformation.Name.trim('.\');
                    'Manufacturer' = $DiskInformation.Manufacturer;
                    'Cylinder' = $DiskInformation.TotalCylinders;
                    'Sectors' = $DiskInformation.TotalSectors
                };
                'partitions' = $diskPartitionInformation
            }
        );    
    }

    return $DiskData;
}