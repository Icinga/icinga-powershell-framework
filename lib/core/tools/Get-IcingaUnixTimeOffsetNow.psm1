<#
.SYNOPSIS
Calculates the offset in seconds between the current Unix time and a specified Unix time or time string.

.DESCRIPTION
The `Get-IcingaUnixTimeOffsetNow` function computes the difference in seconds between the current Unix time and a provided Unix time or time string. If no valid input is provided, the function returns 0.

.PARAMETER TimeString
A string representing a specific time. This string will be converted to Unix time using the `ConvertTo-IcingaUnixTime` function.

.PARAMETER UnixTime
A decimal value representing a specific Unix time. If provided, the offset will be calculated using this value.

.RETURNS
The offset in seconds as a decimal value. If no valid input is provided or the conversion fails, the function returns 0.

.EXAMPLE
PS> Get-IcingaUnixTimeOffsetNow -TimeString "2025-04-20 10:00:00"
Calculates the offset in seconds between the current Unix time and the specified time string.

.EXAMPLE
PS> Get-IcingaUnixTimeOffsetNow -UnixTime 1672531200
Calculates the offset in seconds between the current Unix time and the specified Unix time.

.NOTES
This function depends on the `ConvertTo-IcingaUnixTime` and `Get-IcingaUnixTime` functions to perform time conversions and retrieve the current Unix time.
#>

function Get-IcingaUnixTimeOffsetNow()
{
    param (
        [string]$TimeString = '',
        [decimal]$UnixTime  = 0
    );

    if ([string]::IsNullOrEmpty($TimeString) -And $UnixTime -eq 0) {
        return 0;
    }

    if ([string]::IsNullOrEmpty($TimeString) -eq $FALSE) {
        $UnixTime = ConvertTo-IcingaUnixTime -TimeString $TimeString;

        if ($UnixTime -le 0) {
            return 0;
        }
    }

    $CurrentUnixTime = Get-IcingaUnixTime;

    return ($CurrentUnixTime - $UnixTime);
}
