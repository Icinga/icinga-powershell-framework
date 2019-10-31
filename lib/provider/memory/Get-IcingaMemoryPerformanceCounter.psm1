function Get-IcingaMemoryPerformanceCounter()
{
    $MemoryPercent = New-IcingaPerformanceCounterArray -Counter "\Memory\% committed bytes in use","\Memory\Available Bytes","\Paging File(_Total)\% usage"
    [hashtable]$Initial = @{};
    [hashtable]$MemoryData = @{};

    foreach ($item in $MemoryPercent.Keys) {
        $Initial.Add($item, $MemoryPercent[$item]);
    }

    $MemoryData.Add('Memory Available Bytes', [decimal]($Initial.'\Memory\Available Bytes'.value));
    $MemoryData.Add('Memory Total Bytes', (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory);
    $MemoryData.Add('Memory Used Bytes', $MemoryData.'Memory Total Bytes' - $MemoryData.'Memory Available Bytes');
    $MemoryData.Add('Memory Used %', 100 - ($MemoryData.'Memory Available Bytes' / $MemoryData.'Memory Total Bytes' * 100));
    $MemoryData.Add('PageFile %', $Initial.'\Paging File(_Total)\% usage'.value);

    return $MemoryData;
}