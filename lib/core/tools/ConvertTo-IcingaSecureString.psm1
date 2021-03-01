<#
 # Helper class allowing to easily convert strings into SecureStrings
 # and vice-versa
 #>
function ConvertTo-IcingaSecureString()
{
    param (
        [string]$String
    );

    if ([string]::IsNullOrEmpty($String)) {
        return $null;
    }

    return (ConvertTo-SecureString -AsPlainText $string -Force);
}
