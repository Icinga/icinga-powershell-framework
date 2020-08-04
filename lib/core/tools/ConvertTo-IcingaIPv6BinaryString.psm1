<#
.SYNOPSIS
   Used to convert an IPv6 address to binary.
.DESCRIPTION
   ConvertTo-IcingaIPv6 returns a binary string based on the given IPv6 address.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to convert an IPv6 address to binary string. Its recommended to use ConvertTo-IcingaIPBinaryString as a smart function instead.
.PARAMETER IP
   Used to specify an IPv6 address.
.INPUTS
   System.String
.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-IcingaIPv6BinaryString()
{
    param(
        [string]$IP
    );
    [string]$IP   = Expand-IcingaIPv6String $IP;
    [array]$IPArr = $IP.Split(':');

    $IPArr = $IPArr.ToCharArray();
    $IP = $IPArr | ForEach-Object {
        [System.Convert]::ToString("0x$_", 2).PadLeft(4, '0');
    }
    $IP = $IP -join '';
    $IP = $IP -replace '\s', '';

    return @{
        'value' = $IP;
        'name'  = 'IPv6'
    }
}
