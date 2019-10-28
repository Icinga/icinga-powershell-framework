function Format-IcingaDigitCount()
{
    param(
        [string]$Value,
        [int]$Digits,
        [string]$Symbol = 0
    );

    if ([string]::IsNullOrEmpty($Value)) {
        return $Value;
    }

    $CurrentLength = $Value.Length;
    if ($CurrentLength -ge $Digits) {
        return $Value;
    }

    while ($Value.Length -lt $Digits) {
        $Value = [string]::Format('{0}{1}', $Symbol, $Value);
    }

    return $Value;
}
