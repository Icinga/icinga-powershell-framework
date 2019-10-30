Import-IcingaLib core\tools;

function ConvertFrom-TimeSpan()
{
    param(
        $Seconds
    );

    $TimeSpan = [TimeSpan]::FromSeconds($Seconds);

    return [string]::Format(
        '{0}d {1}h {2}m {3}s',
        $TimeSpan.Days,
        $TimeSpan.Hours,
        $TimeSpan.Minutes,
        $TimeSpan.Seconds
    );
}
