<#
 # Helper class allowing to easily convert strings into SecureStrings
 # and vice-versa
 #>

$SecureString = New-Object -TypeName PSObject;

$SecureString | Add-Member -membertype ScriptMethod -name 'ConvertTo' -value {
    param([string]$string);

    [SecureString]$SecureString = ConvertTo-SecureString -AsPlainText $string -Force;

    return $SecureString;
}

$SecureString | Add-Member -membertype ScriptMethod -name 'ConvertFrom' -value {
    param([SecureString]$SecureString);

    if ($SecureString -eq $null) {
        return '';
    }

    [IntPtr]$BSTR   = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    [string]$String = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    return $String;
}

return $SecureString;