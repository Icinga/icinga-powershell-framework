function ConvertTo-IcingaNumericTimeIndex()
{
    param (
        [int]$TimeValue = 0
    );

    if ($TimeValue -lt 60) {
        return ([string]::Format('{0}s', $TimeValue));
    }

    [decimal]$Minutes = $TimeValue / 60;
    [decimal]$Seconds = $Minutes - [math]::Truncate($Minutes);
    [decimal]$Minutes = [math]::Truncate($Minutes);
    [decimal]$Seconds = [math]::Round(60 * $Seconds, 0);

    $TimeIndex = New-Object -TypeName 'System.Text.StringBuilder';
    $TimeIndex.Append([string]::Format('{0}m', $Minutes)) | Out-Null;

    if ($Seconds -ne 0) {
        $TimeIndex.Append([string]::Format('{0}s', $Seconds)) | Out-Null;
    }

    return $TimeIndex.ToString();
}
