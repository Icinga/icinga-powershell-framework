<#
.SYNOPSIS
    Tests for binary operators with -band if a specific Value contains binary
    operators within a Compare array. In addition you can use a Namespace
    argument to provide a hashtable in which your key values are included to
    reduce the amount of code to write
.DESCRIPTION
    Tests for binary operators with -band if a specific Value contains binary
    operators within a Compare array. In addition you can use a Namespace
    argument to provide a hashtable in which your key values are included to
    reduce the amount of code to write
.EXAMPLE
    PS>Test-IcingaBinaryOperator -Value Ok -Compare EmptyClass, InvalidNameSpace, PermissionError, Ok -Namespace $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo;
    True
.EXAMPLE
    PS>Test-IcingaBinaryOperator -Value 2 -Compare 1,4,8,16,32,64,128,256;
    False
.PARAMETER Value
    The value to check if it is included within the compare argument. This can either be
    the name of the key for a Namespace or a numeric value
.PARAMETER Compare
    An array of values to compare for and check if the value matches with the -band operator
    The array can either contain the key names of your Namespace, numeric values or both combined
.PARAMETER Namespace
    A hashtable object containing values you want to compare for. By providing a hashtable here
    you can use the key names for each value on the Value and Compare argument
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaBinaryOperator()
{
    param (
        $Value                = $null,
        [array]$Compare       = @(),
        [hashtable]$Namespace = $null
    );

    [long]$BinaryValue = 0;

    foreach ($entry in $Compare) {
        if ($null -ne $Namespace) {
            if ($Namespace.ContainsKey($entry)) {
                $BinaryValue += $Namespace[$entry];
            } else {
                if (Test-Numeric $entry) {
                    $BinaryValue += $entry;
                }
            }
        } else {
            $BinaryValue += $entry;
        }
    }

    if ($null -ne $Value -and (Test-Numeric $Value)) {
        if (($Value -band $BinaryValue) -eq $Value) {
            return $TRUE;
        }
    }

    if ($null -ne $Namespace -and $Namespace.ContainsKey($Value)) {
        if (($Namespace[$Value] -band $BinaryValue) -eq $Namespace[$Value]) {
            return $TRUE;
        }
    }

    return $FALSE;
}
