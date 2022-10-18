function Get-IcingaNetworkInterfaceUnits()
{
    param (
        [decimal]$Value = 0,
        [string]$Unit   = ''
    );

    [hashtable]$InterfaceData = @{
        'RawValue'  = $Value;
        'LinkSpeed' = 0;
        'Unit'      = 'Mbit'
    };

    if ([string]::IsNullOrEmpty($Unit) -eq $FALSE) {
        $InterfaceData.LinkSpeed = $Value;
        $InterfaceData.Unit      = $Unit;

        return $InterfaceData;
    }

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
