<#
.SYNOPSIS
    Compares an InputObject of type [array] or [string] to a specified
    include and exclude array filter, returning either if the filter applies
    as true/false or an object of type [array] for filtered InputObject values
.DESCRIPTION
    Compares an InputObject of type [array] or [string] to a specified
    include and exclude array filter, returning either if the filter applies
    as true/false or an object of type [array] for filtered InputObject values.

    The function is designed to work as a general filter approach for check plugins as
    example, to ensure filtering certain values is easy. After comparing the include
    and exclude filter, the function will return True if the input object can be included
    and will return False in case it should not be included.

    For [array] objects, the function will return a filtered [array] object on which all
    values which should be included and excluded were evaluated and only the remaining ones
    are returned.
.PARAMETER InputObject
    The object to compare the filter against. This can be of type [array] or [string].
    Using an [array] object will return a filtered [array] result, while a [string] value
    will return a [bool], if the filter can be applied or not
.PARAMETER Include
    An [array] of values to compare the InputObject against and include only certain input
.PARAMETER Exclude
    An [array] of values to compare the InputObject against and exclude only certain input
.EXAMPLE
    PS> Test-IcingaArrayFilter -InputObject @('icinga2', 'icingapowershell', 'winrm') -Exclude @('icinga2');

    icingapowershell
    winrm
.EXAMPLE
    PS> Test-IcingaArrayFilter -InputObject @('icinga2', 'icingapowershell', 'winrm') -Exclude @('*icinga*');

    winrm
.EXAMPLE
    PS> Test-IcingaArrayFilter -InputObject 'icinga2' -Include @('*icinga*', 'winrm');

    True
.EXAMPLE
    PS> Test-IcingaArrayFilter -InputObject 'icinga2' -Include @('*icinga*', 'winrm') -Exclude @('*icinga*');

    False
#>

function Test-IcingaArrayFilter()
{
    param (
        $InputObject    = $null,
        [array]$Include = @(),
        [array]$Exclude = @()
    );

    [bool]$ReturnArray = $FALSE;

    if ($InputObject -Is [array]) {
        $ReturnArray = $TRUE;
    }

    [array]$FilteredArray = @();

    if ($null -eq $InputObject) {
        if ($ReturnArray) {
            return $InputObject;
        }

        return $FALSE;
    }

    if ($Include.Count -eq 0 -And $Exclude.Count -eq 0) {
        if ($ReturnArray) {
            return $InputObject;
        }

        return $TRUE;
    }

    [bool]$IncludeFound = $FALSE;

    if ($ReturnArray) {
        # Handles if our input object is an array
        # Will return an array object instead of boolean
        foreach ($input in $InputObject) {
            if ((Test-IcingaArrayFilter -InputObject $input -Include $Include -Exclude $Exclude)) {
                $FilteredArray += $input;
            }
        }

        return $FilteredArray;
    } else {
        foreach ($entry in $Exclude) {
            if (([string]$InputObject).ToLower() -Like ([string]$entry).ToLower()) {
                return $FALSE;
            }
        }

        if ($Include.Count -eq 0) {
            return $TRUE;
        }

        foreach ($entry in $Include) {
            if (([string]$InputObject).ToLower() -Like ([string]$entry).ToLower()) {
                $IncludeFound = $TRUE;
                break;
            }
        }

        return $IncludeFound;
    }

    return $IncludeFound;
}
