

function ClassBIOS
{
    # Lets load some bios informations
    $BIOSInformation = Get-CimInstance Win32_BIOS;
    [hashtable]$BIOSData = @{};

    foreach ($bios_properties in $BIOSInformation) {
        #$bios_datails = @{};
        foreach($bios in $bios_properties.CimInstanceProperties) {
            #$bios_datails.Add($bios.Name, $bios.Value);
            $BIOSData.Add($bios.Name, $bios.Value);
        }
        #$BIOSData.Add($bios_datails.DeviceID, $bios_datails);
    }

    return $BIOSData;
}

return ClassBIOS;