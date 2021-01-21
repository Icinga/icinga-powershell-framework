function Get-IcingaUnixTime()
{
    param(
        [switch]$Milliseconds = $FALSE
    );

    if ($Milliseconds) {
        return ([int64](([DateTime]::UtcNow) - (Get-Date '1/1/1970')).TotalMilliseconds / 1000);
    }

    return [int][double]::Parse(
        (Get-Date -UFormat %s -Date (Get-Date).ToUniversalTime())
    );
}
