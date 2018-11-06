param($Config = $null);
#
# Fetch the Disk Hardware informations
#

# Lets load some additional disk informations, besides current data
# It might be useful to get more details about the hardware itself
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