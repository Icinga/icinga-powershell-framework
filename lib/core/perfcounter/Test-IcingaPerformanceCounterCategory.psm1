<#
.SYNOPSIS
   Test if a certain Performance Counter category exist on the systems and returns
   either true or false depending on the state
.DESCRIPTION
   Test if a certain Performance Counter category exist on the systems and returns
   either true or false depending on the state
.FUNCTIONALITY
   Test if a certain Performance Counter category exist on the systems and returns
   either true or false depending on the state
.EXAMPLE
   PS>Test-IcingaPerformanceCounterCategory -Category 'Processor';

   True
.PARAMETER Category
   The name of the category to test for
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaPerformanceCounterCategory()
{
    param (
        [string]$Category
    );

    $Counters = Show-IcingaPerformanceCounterCategories -Filter $Category;

    if ($Counters.Count -eq 0) {
        return $FALSE;
    }

    return $TRUE;
}
