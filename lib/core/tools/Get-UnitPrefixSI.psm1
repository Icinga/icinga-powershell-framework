function Get-UnitPrefixSI()
{
    param(
       [single]$Value
    );

    If ( $Value / [math]::Pow(10, 15) -ge 1 ) {
        return 'PB'
    } elseif ( $Value / [math]::Pow(10, 12) -ge 1 ) {
        return 'TB'
    } elseif ( $Value / [math]::Pow(10, 9) -ge 1 ) {
        return 'GB'
    } elseif ( $Value / [math]::Pow(10, 6) -ge 1 ) {
        return 'MB'
    } elseif ( $Value / [math]::Pow(10, 3) -ge 1 ) {
        return 'KB'
    } else {
        return 'B'
    }
}
