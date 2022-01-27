<#
.SYNOPSIS
    Securely allows to sort arrays for containing objects like hashtables,
    which is not simply done by using Sort-Object, but requires custom expressions
    (ScriptBlocks) to deal with the sorting.
.DESCRIPTION
    Securely allows to sort arrays for containing objects like hashtables,
    which is not simply done by using Sort-Object, but requires custom expressions
    (ScriptBlocks) to deal with the sorting.

    Icinga for Windows does not allow ScriptBlocks inside external modules while using
    JEA profiles. Sorting expressions are ScriptBlocks which are not allowed in JEA
    context. To ensure module developers can still sort objects from inside arrays,
    this function allows to parse the InputObject as array and adding the name of the
    member which should be sorted. In addition it allows configuration if the result
    should be sorted Descending or Ascending (default)
.PARAMETER InputObject
    An array containing all our objects. Defined as Pipeline input
.PARAMETER MemberName
    The member name from within your array objects to sort the result for
.PARAMETER Descending
    Set to sort the output result Descending
.EXAMPLE
    PS> ConvertTo-IcingaSecureSortedArray -InputObject $MyArray -MemberName 'CreationTime';
.EXAMPLE
    PS> ConvertTo-IcingaSecureSortedArray -InputObject $MyArray -MemberName 'CreationTime' -Descending;
.EXAMPLE
    PS> $MyArray | ConvertTo-IcingaSecureSortedArray -MemberName 'CreationTime' -Descending;
#>
function ConvertTo-IcingaSecureSortedArray()
{
    param (
        [Parameter(ValueFromPipeline = $TRUE)]
        [array]$InputObject = @(),
        [string]$MemberName = '',
        [switch]$Descending = $FALSE
    );

    Begin {
        [array]$SortedArray = @();
    }

    Process {
        if ([string]::IsNullOrEmpty($MemberName)) {
            return $InputObject;
        }

        foreach ($entry in $InputObject) {
            $SortedArray += $entry;
        }
    }

    End {
        return ($SortedArray | Sort-Object -Property @{ Expression = { $_.$MemberName }; Descending = $Descending });
    }
}
