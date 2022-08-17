<#
.SYNOPSIS
    Converts strings and all  objects within an array from Default PowerShell encoding
    to UTF8
.DESCRIPTION
    Converts strings and all  objects within an array from Default PowerShell encoding
    to UTF8
.PARAMETER InputObject
    A string or array object to convert
.EXAMPLE
    PS> [array]$ConvertedArgs = ConvertTo-IcingaUTF8Arguments -Arguments $args;
#>

function ConvertTo-IcingaUTF8Value()
{
    param (
        $InputObject = $null
    );

    if ($null -eq $InputObject) {
        return $InputObject;
    }

    if ($InputObject -Is [string]) {
        # If german umlauts are contained, do not convert the value
        # Fixing issues for running checks locally on CLI vs. Icinga Agent
        if ($InputObject -Match "[äöüÄÖÜß]") {
            return $InputObject;
        }

        $InputInBytes = [System.Text.Encoding]::Default.GetBytes($InputObject);

        return ([string]([System.Text.Encoding]::UTF8.GetString($InputInBytes)));
    } elseif ($InputObject -Is [array]) {
        [array]$ArrayObject = @();

        foreach ($entry in $InputObject) {
            if ($entry -Is [array]) {
                $ArrayObject += , (ConvertTo-IcingaUTF8Value -InputObject $entry);
            } else {
                $ArrayObject += ConvertTo-IcingaUTF8Value -InputObject $entry;
            }
        }

        return $ArrayObject;
    }

    # If we are not a string or a array, just return the object
    return $InputObject;
}
