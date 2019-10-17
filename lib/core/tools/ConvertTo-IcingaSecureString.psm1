<#
 # Helper class allowing to easily convert strings into SecureStrings
 # and vice-versa
 #>
function ConvertTo-IcingaSecureString()
{
    param(
        [string]$String
    );

    return (ConvertTo-SecureString -AsPlainText $string -Force);
}
