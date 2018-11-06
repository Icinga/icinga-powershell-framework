$SystemCPU = Get-CimInstance -ClassName 'Win32_Processor';

[int]$NumberOfCPUCores   = 0;
[int]$NumberOfCPUThreads = 0;

if (($SystemCPU.NumberOfCores).GetType() -is [Object]) {
    $SystemCPU.NumberOfCores | Foreach { $NumberOfCPUCores += $_; };
} else {
    $NumberOfCPUCores = $SystemCPU.NumberOfCores;
}

if (($SystemCPU.NumberOfLogicalProcessors).GetType() -is [Object]) {
    $SystemCPU.NumberOfLogicalProcessors | Foreach { $NumberOfCPUThreads += $_; };
} else {
    $NumberOfCPUThreads = $SystemCPU.NumberOfCores;
}

[hashtable]$Overview = @{
    'NumberOfCPUCores'   = $NumberOfCPUCores;
    'NumberOfCPUThreads' = $NumberOfCPUThreads;
};

return $Overview;