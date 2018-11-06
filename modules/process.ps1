param($Config = $null);

$CachedProcessList = $Icinga2.Utils.Modules.GetCacheElement(
    $MyInvocation.MyCommand.Name,
    'ProcessList'
);

$ProcessList     = Get-WmiObject Win32_Process;
$ProcessPerfList = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process;

$NumberOfCPUThreads = $Icinga2.System.NumberOfCPUThreads;

[hashtable]$ProcessReference = @{};
[hashtable]$Processes        = @{};
[hashtable]$ProcessValues    = @{
    FullList = @{ };
    Removed  = @( );
    Added    = $null;
    Modified = @{ };
}

foreach ($process in $ProcessList) {
    [string]$ProcessKey = [string]::Format(
        '{0} [{1}]',
        $process.ProcessName,
        $process.ProcessId
    );

    [hashtable]$ProcessInfo = @{};

    $ProcessInfo.Add('Name', $process.Name);
    $ProcessInfo.Add('ProcessId', $process.ProcessId);
    $ProcessInfo.Add('Priority', $process.Priority);
    $ProcessInfo.Add('PageFileUsage', $process.PageFileUsage);
    $ProcessInfo.Add('ThreadCount', $process.ThreadCount);
    $ProcessInfo.Add('KernelModeTime', $process.KernelModeTime);
    $ProcessInfo.Add('UserModeTime', $process.UserModeTime);
    $ProcessInfo.Add('WorkingSetSize', $process.WorkingSetSize);
    $ProcessInfo.Add('CommandLine', $process.CommandLine);
<#
    # These are not required by now
    $ProcessInfo.Add('Caption', $process.Caption);
    $ProcessInfo.Add('CreationClassName', $process.CreationClassName);
    $ProcessInfo.Add('CreationDate', $process.CreationDate);
    $ProcessInfo.Add('CSCreationClassName', $process.CSCreationClassName);
    $ProcessInfo.Add('CSName', $process.CSName);
    $ProcessInfo.Add('Description', $process.Description);
    $ProcessInfo.Add('ExecutablePath', $process.ExecutablePath);
    $ProcessInfo.Add('ExecutionState', $process.ExecutionState);
    $ProcessInfo.Add('Handle', $process.Handle);
    $ProcessInfo.Add('HandleCount', $process.HandleCount);
    $ProcessInfo.Add('InstallDate', $process.InstallDate);
    $ProcessInfo.Add('MaximumWorkingSetSize', $process.MaximumWorkingSetSize);
    $ProcessInfo.Add('MinimumWorkingSetSize', $process.MinimumWorkingSetSize);
    $ProcessInfo.Add('OSCreationClassName', $process.OSCreationClassName);
    $ProcessInfo.Add('OSName', $process.OSName);
    $ProcessInfo.Add('OtherOperationCount', $process.OtherOperationCount);
    $ProcessInfo.Add('OtherTransferCount', $process.OtherTransferCount);
    $ProcessInfo.Add('PageFaults', $process.PageFaults);
    $ProcessInfo.Add('ParentProcessId', $process.ParentProcessId);
    $ProcessInfo.Add('PeakPageFileUsage', $process.PeakPageFileUsage);
    $ProcessInfo.Add('PeakVirtualSize', $process.PeakVirtualSize);
    $ProcessInfo.Add('PeakWorkingSetSize', $process.PeakWorkingSetSize);
    $ProcessInfo.Add('PrivatePageCount', $process.PrivatePageCount);
    $ProcessInfo.Add('QuotaNonPagedPoolUsage', $process.QuotaNonPagedPoolUsage);
    $ProcessInfo.Add('QuotaPagedPoolUsage', $process.QuotaPagedPoolUsage);
    $ProcessInfo.Add('QuotaPeakNonPagedPoolUsage', $process.QuotaPeakNonPagedPoolUsage);
    $ProcessInfo.Add('QuotaPeakPagedPoolUsage', $process.QuotaPeakPagedPoolUsage);
    $ProcessInfo.Add('ReadOperationCount', $process.ReadOperationCount);
    $ProcessInfo.Add('ReadTransferCount', $process.ReadTransferCount);
    $ProcessInfo.Add('SessionId', $process.SessionId);
    $ProcessInfo.Add('Status', $process.Status);
    $ProcessInfo.Add('TerminationDate', $process.TerminationDate);
    $ProcessInfo.Add('VirtualSize', $process.VirtualSize);
    $ProcessInfo.Add('WindowsVersion', $process.WindowsVersion);
    $ProcessInfo.Add('WriteOperationCount', $process.WriteOperationCount);
    $ProcessInfo.Add('WriteTransferCount', $process.WriteTransferCount);
#>
    $ProcessReference.Add($process.ProcessId, $ProcessKey);
    $Processes.Add($ProcessKey, $ProcessInfo);
}

foreach ($perfdata in $ProcessPerfList) {
    if ($perfdata.Name -eq '_Total') {
        continue;
    }
    if ($ProcessReference.ContainsKey($perfdata.IDProcess)) {
        $Processes[$ProcessReference[$perfdata.IDProcess]].Add(
            'WorkingSetPrivate',
            $perfdata.WorkingSetPrivate
        );
        # Note: In order to get the correct CPU time in % we have to divide the
        #       Processor Time with the amount of threads installed on our CPU
        $Processes[$ProcessReference[$perfdata.IDProcess]].Add(
            'PercentProcessorTime',
            [math]::Round(($perfdata.PercentProcessorTime / $NumberOfCPUThreads), 2)
        );
    }
}

$Processes.Add('count', $Processes.count);

$Icinga2.Utils.Modules.AddCacheElement(
    $MyInvocation.MyCommand.Name,
    'ProcessList',
    $Processes
);

return $Icinga2.Utils.Modules.GetHashtableDiff(
    $Processes.Clone(),
    $CachedProcessList.Clone(),
    @('ProcessId')
);