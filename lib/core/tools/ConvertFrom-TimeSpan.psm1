function ConvertFrom-TimeSpan()
{
    param (
        $Seconds = 0
    );

    if (([string]$Seconds).Contains(',') -Or (Test-Numeric $Seconds)) {
        [decimal]$Seconds = [decimal]([string]$Seconds).Replace(',', '.');
    }

    $Sign = '';
    if ($Seconds -lt 0) {
        $Seconds = [math]::Abs($Seconds);
        $Sign    = '-';
    }

    if ((Test-Numeric $Seconds) -eq $FALSE) {
        return $Seconds;
    }

    $TimeSpan = [TimeSpan]::FromSeconds($Seconds);

    if ($TimeSpan.TotalDays -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}d',
                $Sign,
                ([math]::Round($TimeSpan.TotalDays, 2))
            )
        );
    }
    if ($TimeSpan.TotalHours -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}h',
                $Sign,
                ([math]::Round($TimeSpan.TotalHours, 2))
            )
        );
    }
    if ($TimeSpan.TotalMinutes -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}m',
                $Sign,
                ([math]::Round($TimeSpan.TotalMinutes, 2))
            )
        );
    }
    if ($TimeSpan.TotalSeconds -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}s',
                $Sign,
                ([math]::Round($TimeSpan.TotalSeconds, 2))
            )
        );
    }
    if ($TimeSpan.TotalMilliseconds -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}ms',
                $Sign,
                $TimeSpan.TotalMilliseconds
            )
        );
    }

    if ($Seconds -lt 0.001) {
        return ([string]::Format('{0}{1}us', $Sign, ([math]::Ceiling([decimal]($Seconds*[math]::Pow(10, 6))))));
    }

    return ([string]::Format('{0}s', $Seconds));
}
