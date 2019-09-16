function Format-IcingaDigitCount()
{
    param(
        [string]$Value,
        [int]$Digits
    );

    if ([string]::IsNullOrEmpty($Value)) {
        return $Value;
    }

    $CurrentLength = $Value.Length;
    if ($CurrentLength -ge $Digits) {
        return $Value;
    }

    while ($Value.Length -lt $Digits) {
        $Value = [string]::Format('0{0}', $Value);
    }

    return $Value;
}
