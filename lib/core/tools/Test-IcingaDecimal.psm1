function Test-IcingaDecimal()
{
    param (
        $Value = $null
    );

    [hashtable]$RetValue = @{
        'Value'   = $Value;
        'Decimal' = $FALSE;
    };

    if ($null -eq $Value -Or [string]::IsNullOrEmpty($Value)) {
        return $RetValue;
    }

    $TmpValue = ([string]$Value).Replace(',', '.');

    if ((Test-Numeric $TmpValue) -eq $FALSE) {
        return $RetValue;
    }

    $RetValue.Value   = [decimal]$TmpValue;
    $RetValue.Decimal = $TRUE;

    return $RetValue;
}
