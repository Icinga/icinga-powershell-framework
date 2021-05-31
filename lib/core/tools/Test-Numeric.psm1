<#
.SYNOPSIS
   Tests whether a value is numeric
.DESCRIPTION
   This module tests whether a value is numeric

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> Test-Numeric 32
   True
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>
function Test-Numeric ($number) {
    return $number -Match "^-?[0-9]\d*(\.\d+)?$";
}
