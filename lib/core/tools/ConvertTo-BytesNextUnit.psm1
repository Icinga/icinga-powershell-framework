function ConvertTo-BytesNextUnit()
{
    param (
        [string]$Value = $null,
        [string]$Unit  = $null,
        [array]$Units  = @('B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB')
    );

    [string]$UnitValue = [string]::Format('{0}{1}', $Value, $Unit);

    while ($TRUE) {
        $Unit     = Get-IcingaNextUnitIteration -Unit $Unit -Units $Units;
        [decimal]$NewValue = (Convert-Bytes -Value $UnitValue -Unit $Unit).Value;
        if ($NewValue -ge 1.0) {
            if ($Unit -eq $RetUnit) {
                break;
            }
            $RetValue = [math]::Round([decimal]$NewValue, 2);
            $RetUnit  = $Unit;
        } else {
            if ([string]::IsNullOrEmpty($RetUnit)) {
                $RetValue = $Value;
                $RetUnit  = 'B';
            }
            break;
        }
    }

    return ([string]::Format('{0}{1}', $RetValue, $RetUnit));
}
