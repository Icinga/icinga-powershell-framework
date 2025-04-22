<#
.SYNOPSIS
Converts a time string to a Unix timestamp.

.DESCRIPTION
Converts a given time string like "2025-04-10 20:00:00" to a Unix timestamp.
The function returns 0 if the input is null or empty.
If the input cannot be parsed, it returns -1.
The function uses the UTC time zone for the conversion.

.PARAMETER TimeString
The time string to convert. It should be in a format that can be parsed by [datetime]::Parse, like "2025-04-10 20:00:00"

.EXAMPLE
$UnixTime = ConvertTo-IcingaUnixTime -TimeString "2025-04-10 20:00:00"
$UnixTime
#>

function ConvertTo-IcingaUnixTime()
{
    param (
        [string]$TimeString = $null
    );

    if ([string]::IsNullOrEmpty($TimeString)) {
        return 0;
    }

    try {
        return [decimal][double]::Parse(
            (Get-Date -UFormat %s -Date (Get-Date -Date $TimeString).ToUniversalTime())
        );
    } catch {
        return -1;
    }

    return 0;
}
