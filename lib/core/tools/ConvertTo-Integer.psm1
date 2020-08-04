<#
.SYNOPSIS
   Helper function to convert values to integer if possible
.DESCRIPTION
   Converts an input value to integer if possible in any way. Otherwise it will return the object unmodified

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   Converts an input value to integer if possible in any way. Otherwise it will return the object unmodified
.PARAMETER Value
   Any value/object is analysed and if possible converted to an integer
.INPUTS
   System.Object
.OUTPUTS
   System.Integer

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Integer()
{
    param (
        $Value,
        [switch]$NullAsEmpty
    );

    if ($null -eq $Value) {
        if ($NullAsEmpty) {
            return '';
        }

        return 0;
    }

    if ([string]::IsNullOrEmpty($Value)) {
        if ($NullAsEmpty) {
            return '';
        }

        return 0;
    }

    if ((Test-Numeric $Value)) {
        return $Value;
    }

    $Type = $value.GetType().Name;

    if ($Type -eq 'GpoBoolean' -Or $Type -eq 'Boolean' -Or $Type -eq 'SwitchParameter') {
        return [int]$Value;
    }

    if ($Type -eq 'String') {
        if ($Value.ToLower() -eq 'true' -Or $Value.ToLower() -eq 'yes' -Or $Value.ToLower() -eq 'y') {
            return 1;
        }
        if ($Value.ToLower() -eq 'false' -Or $Value.ToLower() -eq 'no' -Or $Value.ToLower() -eq 'n') {
            return 0;
        }
    }

    return $Value;
}
