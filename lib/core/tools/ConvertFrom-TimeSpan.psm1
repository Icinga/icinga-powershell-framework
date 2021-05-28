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
                ([math]::Round($TimeSpan.TotalDays, 2))
            )
        );
    }
    if ($TimeSpan.TotalHours -ge 1.0) {
        return (
            [string]::Format(
                '{0}h',
                ([math]::Round($TimeSpan.TotalHours, 2))
            )
        );
    }
    if ($TimeSpan.TotalMinutes -ge 1.0) {
        return (
            [string]::Format(
                '{0}m',
                ([math]::Round($TimeSpan.TotalMinutes, 2))
            )
        );
    }
    if ($TimeSpan.TotalSeconds -ge 1.0) {
        return (
            [string]::Format(
                '{0}s',
                ([math]::Round($TimeSpan.TotalSeconds, 2))
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
