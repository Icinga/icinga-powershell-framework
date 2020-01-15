<#
.SYNOPSIS
   Used to convert both IPv4 addresses and IPv6 addresses to binary.
.DESCRIPTION
   ConvertTo-IcingaIPBinaryString returns a binary string based on the given IPv4 address or IPv6 address.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to convert an IPv4 address or IPv6 address to binary string.
.PARAMETER IP
   Used to specify an IPv4 address or IPv6 address.
.INPUTS
   System.String
.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-IcingaIPBinaryString()
{
   param(
      [string]$IP
   );

   $IPArray = $IP.Split(' ');
   $IPList  = @();

   foreach ($entry in $IPArray) {
      if ($entry -like '*.*') {
         $IPList += ConvertTo-IcingaIPv4BinaryString -IP $entry;
      } elseif ($entry -like '*:*') {
         $IPList += ConvertTo-IcingaIPv6BinaryString -IP $entry;
      } else {
         return 'Invalid IP was provided!';
      }
   }

    return $IPList;
}
