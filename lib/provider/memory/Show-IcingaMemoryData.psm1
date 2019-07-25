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