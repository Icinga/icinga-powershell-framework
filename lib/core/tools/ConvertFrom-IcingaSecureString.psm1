function ConvertFrom-IcingaSecureString()
{
    param([SecureString]$SecureString);

    if ($SecureString -eq $null) {
        return '';
    }

    [IntPtr]$BSTR   = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    [string]$String = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    return $String;
}
