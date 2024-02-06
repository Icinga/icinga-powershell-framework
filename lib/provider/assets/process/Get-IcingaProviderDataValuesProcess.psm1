function Get-IcingaProviderDataValuesProcess()
{
    param (
        [array]$IncludeFilter   = @(),
        [array]$ExcludeFilter   = @(),
        [switch]$IncludeDetails = $FALSE
    );

    # Fetch all required process information
    $ProviderName               = 'Process'
    $ProcessData                = New-IcingaProviderObject -Name $ProviderName;
    [array]$ProcessInformation  = Get-IcingaWindowsInformation Win32_Process;
    [array]$ProcessPerfDataList = Get-IcingaWindowsInformation Win32_PerfFormattedData_PerfProc_Process;
    [hashtable]$CPUProcessCache = @{ };
    [hashtable]$MEMProcessCache = @{ };

    # Read our process data and build our metrics object
    foreach ($entry in $ProcessInformation) {
        [string]$ProcessName = $entry.Name.Replace('.exe', '');
        [int]$ProcessId      = [int]$entry.ProcessId;

        if ((Test-IcingaArrayFilter -InputObject $ProcessName -Include $IncludeFilter -Exclude $ExcludeFilter) -eq $FALSE) {
            continue;
        }

        if ((Test-PSCustomObjectMember -PSObject $ProcessData.Metrics -Name $ProcessName) -eq $FALSE) {
            $ProcessData.Metrics                    | Add-Member -MemberType NoteProperty -Name $ProcessName     -Value (New-Object PSCustomObject);
            $ProcessData.Metrics.$ProcessName       | Add-Member -MemberType NoteProperty -Name 'List'           -Value (New-Object PSCustomObject);
            $ProcessData.Metrics.$ProcessName       | Add-Member -MemberType NoteProperty -Name 'Total'          -Value (New-Object PSCustomObject);
            $ProcessData.Metrics.$ProcessName.Total | Add-Member -MemberType NoteProperty -Name 'PageFileUsage'  -Value 0;
            $ProcessData.Metrics.$ProcessName.Total | Add-Member -MemberType NoteProperty -Name 'ThreadCount'    -Value 0;
            $ProcessData.Metrics.$ProcessName.Total | Add-Member -MemberType NoteProperty -Name 'WorkingSetSize' -Value 0;
            $ProcessData.Metrics.$ProcessName.Total | Add-Member -MemberType NoteProperty -Name 'ProcessCount'   -Value 0;
            $ProcessData.Metrics.$ProcessName.Total | Add-Member -MemberType NoteProperty -Name 'CpuUsage'       -Value 0;
            $ProcessData.Metrics.$ProcessName.Total | Add-Member -MemberType NoteProperty -Name 'MemoryUsage'    -Value 0;
        }

        # Detail for each single Process
        $ProcessData.Metrics.$ProcessName.List | Add-Member -MemberType NoteProperty -Name $ProcessId -Value (New-Object PSCustomObject);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'Name'           -Value $ProcessName;
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'ProcessName'    -Value ([string]$entry.Name);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'ProcessId'      -Value $ProcessId;
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'Priority'       -Value ([int]$entry.Priority);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'PageFileUsage'  -Value ([decimal]$entry.PageFileUsage);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'ThreadCount'    -Value ([int]$entry.ThreadCount);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'KernelModeTime' -Value ([decimal]$entry.KernelModeTime);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'UserModeTime'   -Value ([decimal]$entry.UserModeTime);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'WorkingSetSize' -Value ([decimal]$entry.WorkingSetSize);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'CommandLine'    -Value ([string]$entry.CommandLine);
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'CpuUsage'       -Value 0;
        $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'MemoryUsage'    -Value 0;

        # Total data for all processes with a given name
        $ProcessData.Metrics.$ProcessName.Total.PageFileUsage  += ([decimal]$entry.PageFileUsage);
        $ProcessData.Metrics.$ProcessName.Total.ThreadCount    += ([int]$entry.ThreadCount);
        $ProcessData.Metrics.$ProcessName.Total.WorkingSetSize += ([decimal]$entry.WorkingSetSize);
        $ProcessData.Metrics.$ProcessName.Total.ProcessCount   += 1;
    }

    # Process all process performance metrics and add memory and cpu usage to the correct process id
    foreach ($entry in $ProcessPerfDataList) {
        [string]$ProcessName = $entry.Name;
        [int]$ProcessId      = [int]$entry.IDProcess;

        if ($ProcessName.Contains('#')) {
            $ProcessName = $ProcessName.Substring(0, $ProcessName.IndexOf('#'));
        }

        if ((Test-IcingaArrayFilter -InputObject $ProcessName -Include $IncludeFilter -Exclude $ExcludeFilter) -eq $FALSE) {
            continue;
        }

        if ((Test-PSCustomObjectMember -PSObject $ProcessData.Metrics -Name $ProcessName) -eq $FALSE) {
            continue;
        }

        # Add a cache for our Process Data with all CPU loads for every single Process Id
        $CPUProcessCache.Add([string]::Format('{0}|{1}', $ProcessName, [string]$ProcessId), [int]$entry.PercentProcessorTime);
        $MEMProcessCache.Add([string]::Format('{0}|{1}', $ProcessName, [string]$ProcessId), [decimal]$entry.WorkingSetPrivate);

        # Just in case a process id is not present, we should ensure to add it to prevent exceptions
        if ((Test-PSCustomObjectMember -PSObject $ProcessData.Metrics.$ProcessName.List -Name $ProcessId) -eq $FALSE) {
            $ProcessData.Metrics.$ProcessName.List | Add-Member -MemberType NoteProperty -Name $ProcessId -Value (New-Object PSCustomObject);
            $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'CpuUsage'    -Value 0;
            $ProcessData.Metrics.$ProcessName.List.$ProcessId | Add-Member -MemberType NoteProperty -Name 'MemoryUsage' -Value 0;
        }

        $ProcessData.Metrics.$ProcessName.List.$ProcessId.CpuUsage     = [int]$entry.PercentProcessorTime;
        $ProcessData.Metrics.$ProcessName.List.$ProcessId.MemoryUsage  = [decimal]$entry.WorkingSetPrivate;
        $ProcessData.Metrics.$ProcessName.Total.CpuUsage              += [int]$entry.PercentProcessorTime;
        $ProcessData.Metrics.$ProcessName.Total.MemoryUsage           += [decimal]$entry.WorkingSetPrivate;
    }

    # Generaet a "hot" object for our 10 most CPU and Memory consuming process objects
    $ProcessData.Metadata     | Add-Member -MemberType NoteProperty -Name 'Hot'    -Value (New-Object PSCustomObject);
    $ProcessData.Metadata.Hot | Add-Member -MemberType NoteProperty -Name 'Cpu'    -Value (New-Object PSCustomObject);
    $ProcessData.Metadata.Hot | Add-Member -MemberType NoteProperty -Name 'Memory' -Value (New-Object PSCustomObject);

    [array]$TopCPUUsage  = $CPUProcessCache.GetEnumerator() | Sort-Object Value -Descending;
    [array]$TopMEMUsage  = $MEMProcessCache.GetEnumerator() | Sort-Object Value -Descending;
    [int]$IterationIndex = 0;

    while ($IterationIndex -lt 10) {
        if ($TopCPUUsage.Count -gt 0 -And (($TopCPUUsage.Count - 1) -ge $IterationIndex )) {

            if ($TopCPUUsage.Count -gt 1) {
                [string]$CPUProcessName = $TopCPUUsage.Key[$IterationIndex].Split('|')[0];
                [int]$CPUProcessId      = $TopCPUUsage.Key[$IterationIndex].Split('|')[1];
                [int]$CPUUsage          = $TopCPUUsage.Value[$IterationIndex];
            } else {
                [string]$CPUProcessName = $TopCPUUsage.Key.Split('|')[0];
                [int]$CPUProcessId      = $TopCPUUsage.Key.Split('|')[1];
                [int]$CPUUsage          = $TopCPUUsage.Value;
            }
 
            if ($TopCPUUsage.Value[$IterationIndex] -gt 0) {
                $ProcessData.Metadata.Hot.Cpu               | Add-Member -MemberType NoteProperty -Name $CPUProcessId -Value (New-Object PSCustomObject);
                $ProcessData.Metadata.Hot.Cpu.$CPUProcessId | Add-Member -MemberType NoteProperty -Name 'Name'        -Value $CPUProcessName;
                $ProcessData.Metadata.Hot.Cpu.$CPUProcessId | Add-Member -MemberType NoteProperty -Name 'ProcessId'   -Value $CPUProcessId;
                $ProcessData.Metadata.Hot.Cpu.$CPUProcessId | Add-Member -MemberType NoteProperty -Name 'CpuUsage'    -Value $CPUUsage;
            }
        }

        if ($TopMEMUsage.Count -gt 0 -And (($TopMEMUsage.Count - 1) -ge $IterationIndex )) {
            if ($TopMEMUsage.Count -gt 1) {
                [string]$MEMProcessName = $TopMEMUsage.Key[$IterationIndex].Split('|')[0];
                [int]$MEPProcessId      = $TopMEMUsage.Key[$IterationIndex].Split('|')[1];
                [decimal]$MemoryUsage   = $TopMEMUsage.Value[$IterationIndex];
            } else {
                [string]$MEMProcessName = $TopMEMUsage.Key.Split('|')[0];
                [int]$MEPProcessId      = $TopMEMUsage.Key.Split('|')[1];
                [int]$MemoryUsage       = $TopMEMUsage.Value;
            }

            if ($TopMEMUsage.Value[$IterationIndex] -gt 0) {
                $ProcessData.Metadata.Hot.Memory               | Add-Member -MemberType NoteProperty -Name $MEPProcessId -Value (New-Object PSCustomObject);
                $ProcessData.Metadata.Hot.Memory.$MEPProcessId | Add-Member -MemberType NoteProperty -Name 'Name'        -Value $MEMProcessName;
                $ProcessData.Metadata.Hot.Memory.$MEPProcessId | Add-Member -MemberType NoteProperty -Name 'ProcessId'   -Value $MEPProcessId;
                $ProcessData.Metadata.Hot.Memory.$MEPProcessId | Add-Member -MemberType NoteProperty -Name 'MemoryUsage' -Value $MemoryUsage;
            }
        }

        $IterationIndex += 1;
    }

    $CPUProcessCache     = $null;
    $MEMProcessCache     = $null;
    $ProcessInformation  = $null;
    $ProcessPerfDataList = $null;
    $TopCPUUsage         = $null;
    $TopMEMUsage         = $null;

    return $ProcessData;
}
