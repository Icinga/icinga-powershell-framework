<#
.SYNOPSIS
   Used to convert an IPv4 address to binary.
.DESCRIPTION
   ConvertTo-IcingaIPv6 returns a binary string based on the given IPv4 address.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to convert an IPv4 address to binary string. Its recommended to use ConvertTo-IcingaIPBinaryString as a smart function instead.
.PARAMETER IP
   Used to specify an IPv4 address.
.INPUTS
   System.String
.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-IcingaIPv4BinaryString()
{
   param(
      [string]$IP
   );

   try {
      $IP = $IP -split '\.' | ForEach-Object {    
         [System.Convert]::ToString($_, 2).PadLeft(8, '0');
      }
      $IP = $IP -join '';
      $IP = $IP -replace '\s','';
   } catch {
       # Todo: Should we handle errors? It might happen due to faulty routes or unhandled route config
       #       we throw errors which should have no effect at all
       return $null;
   }

   return @{
      'value' = $IP;
      'name' = 'IPv4'
   }
}
