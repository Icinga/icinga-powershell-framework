param($Config = $null);
#
# Fetch the Memory Hardware informations
#

# Lets load some additional memory informations, besides current performance counters
# It might be useful to get more details about the hardware itself
$MemoryInformations = Get-CimInstance Win32_PhysicalMemory;
$capacity = $MemoryInformations | Measure-Object -Property capacity -Sum;

# Lets load the details from our RAM modules
[hashtable]$PhysicalMemoryData = @{};

$PhysicalMemoryData.Add('Modules', $capacity.Count);

foreach($memory_object in $MemoryInformations) {
    $memory_datails = @{};
    $memory_datails.Add('caption', $memory_object.Caption);
    $memory_datails.Add('desc', $memory_object.Description);
    $memory_datails.Add('name', $memory_object.Name);
    $memory_datails.Add('install_date', $memory_object.InstallDate);
    $memory_datails.Add('status', $memory_object.Status);
    $memory_datails.Add('creation_class_name', $memory_object.CreationClassName);
    $memory_datails.Add('manufacturer', $memory_object.Manufacturer);
    $memory_datails.Add('model', $memory_object.Model);
    $memory_datails.Add('other_identifiying_info', $memory_object.OtherIdentifyingInfo);
    $memory_datails.Add('part_number', $memory_object.PartNumber);
    $memory_datails.Add('powered_on', $memory_object.PoweredOn);
    $memory_datails.Add('serial_number', $memory_object.SerialNumber);
    $memory_datails.Add('sku', $memory_object.SKU);
    $memory_datails.Add('tag', $memory_object.Tag);
    $memory_datails.Add('version', $memory_object.Version);
    $memory_datails.Add('hot_swappable', $memory_object.HotSwappable);
    $memory_datails.Add('removable', $memory_object.Removable);
    $memory_datails.Add('replaceable', $memory_object.Replaceable);
    $memory_datails.Add('form_factor', $memory_object.FormFactor);
    $memory_datails.Add('bank_label', $memory_object.BankLabel);
    $memory_datails.Add('capacity', $memory_object.Capacity);
    $memory_datails.Add('data_width', $memory_object.DataWidth);
    $memory_datails.Add('interleave_position', $memory_object.InterleavePosition);
    $memory_datails.Add('memory_type', $memory_object.MemoryType);
    $memory_datails.Add('position_in_row', $memory_object.PositionInRow);
    $memory_datails.Add('speed', $memory_object.Speed);
    $memory_datails.Add('total_width', $memory_object.TotalWidth);
    $memory_datails.Add('attributes', $memory_object.Attributes);
    $memory_datails.Add('configured_clock_speed', $memory_object.ConfiguredClockSpeed);
    $memory_datails.Add('configured_voltage', $memory_object.ConfiguredVoltage);
    $memory_datails.Add('device_locator', $memory_object.DeviceLocator);
    $memory_datails.Add('interleave_data_depth', $memory_object.InterleaveDataDepth);
    $memory_datails.Add('max_voltage', $memory_object.MaxVoltage);
    $memory_datails.Add('min_voltage', $memory_object.MinVoltage);
    $memory_datails.Add('smbios_memory_type', $memory_object.SMBIOSMemoryType);
    $memory_datails.Add('type_detail', $memory_object.TypeDetail);
    $memory_datails.Add('ps_computer_name', $memory_object.PSComputerName);

    $PhysicalMemoryData.Add($memory_object.Tag, $memory_datails);
}

return $PhysicalMemoryData;