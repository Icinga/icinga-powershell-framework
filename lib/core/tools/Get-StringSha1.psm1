function Get-StringSha1()
{
    param (
        [string]$Content
    );

    $CryptoAlgorithm = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider;
    $ContentHash     = [System.Text.Encoding]::UTF8.GetBytes($Content);
    $ContentBytes    = $CryptoAlgorithm.ComputeHash($ContentHash);
    $OutputHash      = '';

    foreach ($byte in $ContentBytes) {
        $OutputHash += $byte.ToString()
    }

    return $OutputHash;
}
