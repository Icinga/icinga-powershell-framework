function ConvertFrom-Percent()
{
    param (
        $Value       = $null,
        $Percent     = $null,
        [int]$Digits = 0
    );

    if ($null -eq $Value -Or $null -eq $Percent) {
        return 0;
    }

    return ([math]::Round(($Value / 100 * $Percent), $Digits));
}
