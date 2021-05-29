function Convert-IcingaPluginValueToString()
{
    param (
        $Value,
        [string]$Unit         = '',
        [string]$OriginalUnit = ''
    );

    $AdjustedValue = $Value;

    if ([string]::IsNullOrEmpty($OriginalUnit)) {
        $OriginalUnit = $Unit;
    }

    try {
        $AdjustedValue = ([math]::Round([decimal]$Value, 6))
    } catch {
        $AdjustedValue = $Value;
    }

    if ($Unit -eq '%' -Or [string]::IsNullOrEmpty($Unit)) {
        return ([string]::Format('{0}{1}', $AdjustedValue, $Unit));
    }

    switch ($OriginalUnit) {
        { ($_ -eq "Kbit") -or ($_ -eq "Mbit") -or ($_ -eq "Gbit") -or ($_ -eq "Tbit") -or ($_ -eq "Pbit") -or ($_ -eq "Ebit") -or ($_ -eq "Zbit") -or ($_ -eq "Ybit") } {
            $TransferSpeed = Get-IcingaNetworkInterfaceUnits -Value $Value;
            return ([string]::Format('{0}{1}', $TransferSpeed.LinkSpeed, $TransferSpeed.Unit));
        };
        { ($_ -eq "B") -or ($_ -eq "KiB") -or ($_ -eq "MiB") -or ($_ -eq "GiB") -or ($_ -eq "TiB") -or ($_ -eq "PiB") -or ($_ -eq "EiB") -or ($_ -eq "ZiB") -or ($_ -eq "YiB") } {
            return (ConvertTo-BytesNextUnit -Value $Value -Unit $Unit -Units @('B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB'));
        };
        { ($_ -eq "KB") -or ($_ -eq "MB") -or ($_ -eq "GB") -or ($_ -eq "TB") -or ($_ -eq "PB") -or ($_ -eq "EB") -or ($_ -eq "ZB") -or ($_ -eq "YB") } {
            return (ConvertTo-BytesNextUnit -Value $Value -Unit $Unit -Units @('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'));
        };
        's' {
            return (ConvertFrom-TimeSpan -Seconds $AdjustedValue)
        };
    }

    return ([string]::Format('{0}{1}', $AdjustedValue, $Unit));
}
