function Get-UnitPrefixIEC()
{
    param(
       [single]$Value
    );

    If ( $Value / [math]::Pow(2, 50) -ge 1 ) {
        return 'PiB'
    } elseif ( $Value / [math]::Pow(2, 40) -ge 1 ) {
        return 'TiB'
    } elseif ( $Value / [math]::Pow(2, 30) -ge 1 ) {
        return 'GiB'
    } elseif ( $Value / [math]::Pow(2, 20) -ge 1 ) {
        return 'MiB'
    } elseif ( $Value / [math]::Pow(2, 10) -ge 1 ) {
        return 'KiB'
    } else {
        return 'B'
    }
}

