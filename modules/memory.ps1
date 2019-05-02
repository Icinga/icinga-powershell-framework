

param($Config = $null);

function ClassMemory
{
    param($Config = $null);
    # This will return a hashtable with every single counter
    # We specify within the array
    $counter = Get-Icinga-Counter -CounterArray @(
        '\Memory\Available Bytes',
        '\Memory\% Committed Bytes In Use',
        '\Memory\Committed Bytes',
        '\Memory\Cache Bytes',
        '\Memory\Pool Nonpaged Bytes',
        '\Memory\Pages/sec',
        '\Memory\Page Reads/sec',
        '\Memory\Page Writes/sec',
        '\Memory\Pages Input/sec',
        '\Memory\Pages Output/sec',
        '\Paging File(*)\% Usage',
        '\Paging File(*)\% Usage Peak'
    );

    # Lets load some additional memory informations, besides current performance counters
    $ComputerInformations = Get-CimInstance Win32_ComputerSystem;
    $counter.Add('\Memory\Physical Memory Total Bytes', @{ 'value' = $ComputerInformations.TotalPhysicalMemory; 'sample' = @{ }; });

    return $counter;
}

return ClassMemory -Config $Config;