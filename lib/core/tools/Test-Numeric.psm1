<#
.SYNOPSIS
   Tests whether a value is numeric
.DESCRIPTION
   This module tests whether a value is numeric

   More Information on https://github.com/LordHepipud/icinga-module-windows
.EXAMPLE
   PS> Test-Numeric 32
   True
.LINK
   https://github.com/LordHepipud/icinga-module-windows
.NOTES
#>
function Test-Numeric ($number) {
    return $number -Match "^[\d\.]+$";
}
