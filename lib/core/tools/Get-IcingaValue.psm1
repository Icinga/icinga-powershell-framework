<#
.SYNOPSIS
   Compares two numeric input values and returns the lower or higher value
.DESCRIPTION
   Compares two numeric numbers and returns either the higher or lower value
   depending on the configuration of the argument

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   Compares two numeric input values and returns the lower or higher value
.PARAMETER Value
   The input value to check for
.PARAMETER Compare
   The value to compare against
.PARAMETER Minimum
   Configures the command to return the lower number of both inputs
.PARAMETER Maximum
   Configures the command to return the higher number of both inputs
.INPUTS
   System.Integer
.OUTPUTS
   System.Integer
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Get-IcingaValue()
{
    param(
        $Value,
        $Compare,
        [switch]$Minimum = $FALSE,
        [switch]$Maximum = $FALSE
    );

    # If none of both is set, return the current value
    if (-Not $Minimum -And -Not $Maximum) {
        return $Value;
    }

    # Return the lower value
    if ($Minimum) {
        # If the value is greater or equal the compared value, return the compared one
        if ($Value -ge $Compare) {
            return $Compare;
        }

        # Otherwise return the value itself
        return $Value;
    }

    # Return the higher value
    if ($Maximum) {
        # If the value is greater or equal the compared one, return the value
        if ($Value -ge $Compare) {
            return $Value;
        }

        # Otherwise return the compared value
        return $Compare;
    }

    # Shouldnt happen anyway
    return $Value;
}
