<#
.SYNOPSIS
   Used to Expand an IPv6 address.
.DESCRIPTION
   Expand-IcingaIPv6String returns the expanded version of an IPv6 address.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to expand an IPv6 address.
.EXAMPLE
   PS> Expand-IcingaIPv6String ffe8::71:ab:   
   FFE8:0000:0000:0000:0000:0071:00AB:0000
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

function Expand-IcingaIPv6String()
{
    param (
        [String]$IP
    );

    $Counter = 0
    $RelV = -1

    for($Index = 0; $Index -lt $IP.Length; $Index++) {
        if ($IP[$Index] -eq ':') {
            $Counter++
            if (($Index - 1) -ge 0 -and $IP[$Index - 1] -eq ':'){
                $RelV = $Index
            }
        }
    }

    if ($RelV -lt 0 -and $Counter -ne 7) {
        Write-Host "Invalid IP was provided!";
        return $null;
    }

    if ($Counter -lt 7) {
        $IP = $IP.Substring(0, $RelV) + (':'*(7 - $Counter)) + $IP.Substring($RelV)
    }

    $Result = @();

    foreach ($SIP in $IP -split ':') {
        $Value = 0;
        [int]::TryParse(
            $SIP,
            [System.Globalization.NumberStyles]::HexNumber,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [Ref]$Value
        ) | Out-Null;
        $Result += ('{0:X4}' -f $Value)
    }
    $Result = $Result -join ':';

    return $Result;
}