<#
.SYNOPSIS
   Sets nummeric values to be negative
.DESCRIPTION
   This module sets a numeric value to be negative.
   e.g 12 to -12

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> Set-NumericNegative 32
   -32
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>


function Set-NumericNegative()
{
    param(
        $Value
    );

    $Value = $Value * -1;

    return $Value;
}