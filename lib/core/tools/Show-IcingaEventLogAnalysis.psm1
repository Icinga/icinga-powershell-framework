function Show-IcingaEventLogAnalysis()
{
    param (
        [string]$LogName         = 'Application'
    );

    Write-IcingaConsoleNotice 'Analysing EventLog "{0}"...' -Objects $LogName;

    Start-IcingaTimer 'EventLog Analyser';

    try {
        [array]$BasicLogArray = Get-WinEvent -ListLog $LogName -ErrorAction Stop;
        $BasicLogData         = $BasicLogArray[0];
    } catch {
        Write-IcingaConsoleError 'Failed to fetch data for EventLog "{0}". Probably this log does not exist.' -Objects $LogName;
        return;
    }

    Write-IcingaConsoleNotice 'Logging Mode: {0}' -Objects $BasicLogData.LogMode;
    Write-IcingaConsoleNotice 'Maximum Size: {0} GB' -Objects ([math]::Round((Convert-Bytes -Value $BasicLogData.MaximumSizeInBytes -Unit 'GB').value, 2));
    Write-IcingaConsoleNotice 'Current Entries: {0}' -Objects $BasicLogData.RecordCount;

    [hashtable]$LogAnalysis = @{
        'Day'    = @{
            'Entries' = @{ };
            'Count'   = 0;
            'Average' = 0;
            'Maximum' = 0;
        };
        'Hour'   = @{
            'Entries' = @{ };
            'Count'   = 0;
            'Average' = 0;
            'Maximum' = 0;
        };
        'Minute' = @{
            'Entries' = @{ };
            'Count'   = 0;
            'Average' = 0;
            'Maximum' = 0;
        };
    };

    $LogData             = Get-WinEvent -LogName $LogName;
    [string]$NewestEntry = $null;
    [string]$OldestEntry = $null;

    foreach ($entry in $LogData) {
        [string]$DayOfLogging = $entry.TimeCreated.ToString('yyyy\/MM\/dd');
        [string]$HourOfLogging = $entry.TimeCreated.ToString('yyyy\/MM\/dd-HH');
        [string]$MinuteOfLogging = $entry.TimeCreated.ToString('yyyy\/MM\/dd-HH-mm');

        $OldestEntry = $entry.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss');

        if ([string]::IsNullOrEmpty($NewestEntry)) {
            $NewestEntry = $OldestEntry;
        }

        if ($LogAnalysis.Day.Entries.ContainsKey($DayOfLogging) -eq $FALSE) {
            $LogAnalysis.Day.Entries.Add($DayOfLogging, 0);
        }

        if ($LogAnalysis.Hour.Entries.ContainsKey($HourOfLogging) -eq $FALSE) {
            $LogAnalysis.Hour.Entries.Add($HourOfLogging, 0);
        }

        if ($LogAnalysis.Minute.Entries.ContainsKey($MinuteOfLogging) -eq $FALSE) {
            $LogAnalysis.Minute.Entries.Add($MinuteOfLogging, 0);
        }

        $LogAnalysis.Day.Entries[$DayOfLogging]       += 1;
        $LogAnalysis.Hour.Entries[$HourOfLogging]     += 1;
        $LogAnalysis.Minute.Entries[$MinuteOfLogging] += 1;

        $LogAnalysis.Day.Count    += 1;
        $LogAnalysis.Hour.Count   += 1;
        $LogAnalysis.Minute.Count += 1;

        $LogAnalysis.Day.Average    = [math]::Ceiling($LogAnalysis.Day.Count / $LogAnalysis.Day.Entries.Count);
        $LogAnalysis.Hour.Average   = [math]::Ceiling($LogAnalysis.Hour.Count / $LogAnalysis.Hour.Entries.Count);
        $LogAnalysis.Minute.Average = [math]::Ceiling($LogAnalysis.Minute.Count / $LogAnalysis.Minute.Entries.Count);
    }

    foreach ($value in $LogAnalysis.Day.Entries.Values) {
        $LogAnalysis.Day.Maximum = Get-IcingaValue -Value $value -Compare $LogAnalysis.Day.Maximum -Maximum;
    }
    foreach ($value in $LogAnalysis.Hour.Entries.Values) {
        $LogAnalysis.Hour.Maximum = Get-IcingaValue -Value $value -Compare $LogAnalysis.Hour.Maximum -Maximum;
    }
    foreach ($value in $LogAnalysis.Minute.Entries.Values) {
        $LogAnalysis.Minute.Maximum = Get-IcingaValue -Value $value -Compare $LogAnalysis.Minute.Maximum -Maximum;
    }
    Stop-IcingaTimer 'EventLog Analyser';

    Write-IcingaConsoleNotice 'Average Logs per Day: {0}' -Objects $LogAnalysis.Day.Average;
    Write-IcingaConsoleNotice 'Average Logs per Hour: {0}' -Objects $LogAnalysis.Hour.Average;
    Write-IcingaConsoleNotice 'Average Logs per Minute: {0}' -Objects $LogAnalysis.Minute.Average;
    Write-IcingaConsoleNotice 'Maximum Logs per Day: {0}' -Objects $LogAnalysis.Day.Maximum;
    Write-IcingaConsoleNotice 'Maximum Logs per Hour: {0}' -Objects $LogAnalysis.Hour.Maximum;
    Write-IcingaConsoleNotice 'Maximum Logs per Minute: {0}' -Objects $LogAnalysis.Minute.Maximum;
    Write-IcingaConsoleNotice 'Newest entry timestamp: {0}' -Objects $NewestEntry;
    Write-IcingaConsoleNotice 'Oldest entry timestamp: {0}' -Objects $OldestEntry;
    Write-IcingaConsoleNotice 'Analysing Time: {0}s' -Objects ([math]::Round((Get-IcingaTimer 'EventLog Analyser').Elapsed.TotalSeconds, 2));
}
