<#
.SYNOPSIS
    Compare-IcingaUnixTimeWithDateTime compares a DateTime-Object with the current DateTime and returns the offset between these values as Integer
.DESCRIPTION
    Compare-IcingaUnixTimeWithDateTime compares a DateTime-Object with the current DateTime and returns the offset between these values as Integer
.PARAMETER DateTime
    DateTime object you want to compare with the Universal Time
.INPUTS
    System.DateTime
.OUTPUTS
    System.Int64
#>
function Compare-IcingaUnixTimeWithDateTime() {
    param (
        [datetime]$DateTime
    );

    # This is when the computer starts counting time
    $UnixEpochStart = (New-Object DateTime 1970, 1, 1, 0, 0, 0, ([DateTimeKind]::Utc));
    # We convert the creation and current time to seconds
    $CreationTime   = [long][System.Math]::Floor((($DateTime.ToUniversalTime() - $UnixEpochStart).Ticks / [timespan]::TicksPerSecond));
    $CurrentTime    = Get-IcingaUnixTime;

    # To find out, from the snapshot creation time to the current time, how many seconds are,
    # you have to subtract from the (Current Time in s) the (Creation Time in s)
    return ($CurrentTime - $CreationTime);
}
