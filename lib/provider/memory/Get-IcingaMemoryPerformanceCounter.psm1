function Get-IcingaMemoryPerformanceCounter()
{
    $MemoryPercent = New-IcingaPerformanceCounterArray -Counter "\Memory\% committed bytes in use","\Memory\committed bytes","\Paging File(_Total)\% usage"
    [hashtable]$Result = @{};

    foreach ($item in $MemoryPercent.Keys) {
        $Result.Add($item, $MemoryPercent[$item]);
    }

    return $Result;
}

function Get-IcingaMemoryPerformanceCounterFormated()
{
    [hashtable]$Result = @{};
    $Result.Add('Memory %', (Get-IcingaMemoryPerformanceCounter).'\Memory\% committed bytes in use'.value);
    $Result.Add('Memory GigaByte', (ConvertTo-GigaByte ([decimal](Get-IcingaMemoryPerformanceCounter).'\Memory\committed bytes'.value) -Unit Byte));
    $Result.Add('PageFile %', (Get-IcingaMemoryPerformanceCounter).'\Paging File(_Total)\% usage'.value);
    
    return $Result;
}