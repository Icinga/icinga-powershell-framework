Import-IcingaLib core\tools;

function ConvertFrom-TimeSpan()
{
    param(
        $Seconds
    );

    $TimeSpan = [TimeSpan]::FromSeconds($Seconds);

    return [string]::Format(
        'Days: {0} Hours: {1} Minutes: {2} Seconds: {3}',
        $TimeSpan.Days,
        $TimeSpan.Hours,
        $TimeSpan.Minutes,
        $TimeSpan.Seconds
    );
}
