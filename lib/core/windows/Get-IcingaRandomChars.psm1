function Get-IcingaRandomChars()
{
    param (
        [int]$Count      = 10,
        [string]$Symbols = 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!§$%&/()=?}][{@#*+'
    );

    $RandomChars = '';

    if ([string]::IsNullOrEmpty($Symbols)) {
        return $RandomChars;
    }

    while ($Count -gt 0) {

        [int]$SymbolLength = $Symbols.Length;
        $RandomValue       = Get-Random -Minimum 0 -Maximum ($SymbolLength - 1);
        $RandomChars       += $Symbols[$RandomValue];
        $Count             -= 1;
    }

    return $RandomChars;
}
