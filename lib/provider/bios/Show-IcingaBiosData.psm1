function Show-IcingaBiosData()
{
    $BIOSInformation = Get-CimInstance Win32_BIOS;
    [hashtable]$BIOSData = @{};

    foreach ($bios_properties in $BIOSInformation) {
        foreach($bios in $bios_properties.CimInstanceProperties) {
            $BIOSData.Add($bios.Name, $bios.Value);
        }
    }

    return $BIOSData;
}