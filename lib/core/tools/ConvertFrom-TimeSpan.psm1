Import-IcingaLib core\tools;

function ConvertFrom-TimeSpan()
{
    param (
        $Seconds = 0
    );

    $TimeSpan = [TimeSpan]::FromSeconds($Seconds);

    if ($TimeSpan.TotalDays -ge 1.0) {
        return (
            [string]::Format(
                '{0}d',
                $TimeSpan.TotalDays
            )
        );
    }
    if ($TimeSpan.TotalHours -ge 1.0) {
        return (
            [string]::Format(
                '{0}h',
                $TimeSpan.TotalHours
            )
        );
    }
    if ($TimeSpan.TotalMinutes -ge 1.0) {
        return (
            [string]::Format(
                '{0}m',
                $TimeSpan.TotalMinutes
            )
        );
    }
    if ($TimeSpan.TotalSeconds -ge 1.0) {
        return (
            [string]::Format(
                '{0}s',
                $TimeSpan.TotalSeconds
            )
        );
    }
    if ($TimeSpan.TotalMilliseconds -gt 0) {
        return (
            [string]::Format(
                '{0}ms',
                $TimeSpan.TotalMilliseconds
            )
        );
    }

    return ([string]::Format('{0}s', $Seconds));
}
