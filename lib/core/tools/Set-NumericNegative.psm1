<#
.SYNOPSIS
   Sets nummeric values to be negative
.DESCRIPTION
   This module sets a numeric value to be negative.
   e.g 12 to -12

   More Information on https://github.com/LordHepipud/icinga-module-windows
.EXAMPLE
   PS> Set-NumericNegative 32
   -32
.LINK
   https://github.com/LordHepipud/icinga-module-windows
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