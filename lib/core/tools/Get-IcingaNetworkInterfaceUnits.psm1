function Get-IcingaNetworkInterfaceUnits()
{
    param (
        [long]$Value
    );

    [hashtable]$InterfaceData = @{
        'RawValue'  = $Value;
        'LinkSpeed' = 0;
        'Unit'      = 'Mbit'
    };

    [decimal]$result = ($Value / [Math]::Pow(10, 6));

    if ($result -ge 1000) {
        $InterfaceData.LinkSpeed = [decimal]($result / 1000);
        $InterfaceData.Unit      = 'Gbit';
    } else {
        $InterfaceData.LinkSpeed = $result;
        $InterfaceData.Unit      = 'Mbit';
    }

    return $InterfaceData;
}
