<#
.SYNOPSIS
    Securely reads data from enum providers and returns either a found value
    from the provider or the given value, in case it was not found or does not
    match our index
.DESCRIPTION
    Securely reads data from enum providers and returns either a found value
    from the provider or the given value, in case it was not found or does not
    match our index
.FUNCTIONALITY
    Securely reads data from enum providers and returns either a found value
    from the provider or the given value, in case it was not found or does not
    match our index
.EXAMPLE
    PS> Get-IcingaProviderEnumData -Enum $ProviderEnums -Key 'DiskBusType' -Index 6;
    PS> Fibre Channel
.PARAMETER Enum
    The Icinga for Windows enum provider variable
.PARAMETER Key
    The key of the index of our enum we want to access
.PARAMETER Index
    They index key for your provided enum. Can either the a numeric value or string
.INPUTS
    System.Object
.OUTPUTS
    System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaProviderEnumData()
{
    param (
        $Enum  = $null,
        $Key   = $null,
        $Index = ''
    );

    if ($null -eq $Enum -Or $null -eq $Key) {
        return $Index;
    }

    if ($Enum -IsNot [hashtable]) {
        return $Index;
    }

    if ($Enum.ContainsKey($Key) -eq $FALSE) {
        return $Index;
    }

    [array]$Keys = $Enum[$Key].Keys;

    if (Test-Numeric -number $Keys[0]) {
        # Handle Providers with numeric indexes
        if ((Test-Numeric -number $Index)) {
            # Our index is numeric, return the value if it exists
            if ($Enum[$Key].ContainsKey([int]$Index)) {
                return $Enum[$Key][[int]$Index];
            }
        }
    } else {
        # Handle Providers with string indexes
        if ($Enum[$Key].ContainsKey([string]$Index)) {
            return $Enum[$Key][[string]$Index];
        }
    }

    # If above rules do not apply, simply return the index as it is
    return $Index;
}
