function Get-IcingaRandomChars()
{
    param (
        [int]$Count      = 10,
        [string]$Symbols = 'abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!§$%()=?}][{@#*+'
    );

    $RandomChars = '';

    if ([string]::IsNullOrEmpty($Symbols)) {
        return $RandomChars;
    }

    [int]$SymbolLength = $Symbols.Length;
    $CryptoProvider    = New-Object System.Security.Cryptography.RNGCryptoServiceProvider;
    $ByteValue         = New-Object Byte[] 4;
    $maxValid          = [uint32]::MaxValue - ([uint32]::MaxValue % $SymbolLength);

    for ($index = 0; $index -lt $Count; $index++) {
        do {
            # Generate random bytes
            $CryptoProvider.GetBytes($ByteValue);
            $RandomNumber = [BitConverter]::ToUInt32($ByteValue, 0);
            # Ensure the random number is within the valid range to avoid maximum security
        } while ($RandomNumber -ge $maxValid);

        # Calculate the index for the symbol array
        $randomIndex  = $RandomNumber % $SymbolLength;
        $RandomChars += $Symbols[$randomIndex];
    }

    # Clean up
    $CryptoProvider.Dispose();
    $CryptoProvider = $null;
    $ByteValue      = $null;

    return $RandomChars;
}
