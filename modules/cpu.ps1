param($Config = $null);

function ClassCPU
{
    param($Config = $null);

    # This will return a hashtable with every single counter
    # We specify within the array
    $counter = Get-Icinga-Counter -CounterArray @(
        '\Processor(*)\% Processor Time',
        '\System\Processor Queue Length',
        '\System\Threads'
    );

    return $counter;
}

return ClassCPU -Config $Config;