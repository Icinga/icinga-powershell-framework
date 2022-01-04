function Test-IcingaValidJSON()
{
    param (
        [string]$String = '',
        [string]$File   = ''
    );

    if ([string]::IsNullOrEmpty($File) -eq $FALSE) {
        if ((Test-Path $File) -eq $FALSE) {
            return $FALSE;
        }

        $String = Get-Content -Path $File -Raw;
    }
    try {
        # Test the conversion to JSON and return false on failure and true on success
        ConvertFrom-Json -InputObject $String -ErrorAction Stop | Out-Null;
    } catch {
        return $FALSE;
    }

    return $TRUE;
}
