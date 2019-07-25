function Get-IcingaMemoryPerformanceCounter()
{
    $MemoryStart       = (Show-IcingaPerformanceCounters -CounterCategory 'Memory').Keys;
    $MemoryCounter     = New-IcingaPerformanceCounterArray -Counter $MemoryStart;
    [hashtable]$Result = @{};

    foreach ($item in $MemoryCounter.Keys) {
        $counter       = $item.trimstart('\Memory\');
        $Result.Add($counter, $MemoryCounter[$item]);
    }

    return $Result;
}
