function Get-IcingaMemoryPerformanceCounter()
{
    $MemoryStart       = (Show-IcingaPerformanceCounters -CounterCategory 'Memory');
    $MemoryCounter     = New-IcingaPerformanceCounterArray -Counter $MemoryStart;
    [hashtable]$Result = @{};

    foreach ($item in $MemoryCounter.Keys) {
        $counter       = $item.trimstart('\Memory\');
        $Result.Add($counter, $MemoryCounter[$item]);
    }

    return $Result;
}

function Get-IcingaPageFilePerformanceCounter()
{
    $PageFileStart       = (Show-IcingaPerformanceCounters -CounterCategory 'Paging File');
    $PageFileCounter     = New-IcingaPerformanceCounterArray -Counter $PageFileStart;
    [hashtable]$Result = @{};

    foreach ($item in $PageFileCounter.Keys) {
        $counter       = $item.trimstart('\Paging File\');
        $Result.Add($counter, $PageFileCounter[$item]);
    }

    return $Result;
}