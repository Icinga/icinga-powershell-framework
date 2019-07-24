Import-IcingaLib provider\enums;
Import-IcingaLib provider\cpu;

function Add-IcingaProcessPerfData()
{
    param($ProcessList, $ProcessKey, $Process);

    if ($ProcessList.ContainsKey($ProcessKey) -eq $FALSE) {
        $ProcessList.Add($ProcessKey, $Process.$ProcessKey);
    } else {
        $ProcessList[$ProcessKey] += $Process.$ProcessKey;
    }
}

function Get-IcingaProcessData {

    param(
        [array]$Process
    );

    $ProcessInformation     = Get-WmiObject Win32_Process;
    $ProcessPerfDataList    = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process;
    $CPUCoreCount           = Get-IcingaCPUCount;
    
    
    [hashtable]$ProcessData        = @{};
    [hashtable]$ProcessList        = @{};
    [hashtable]$ProcessNamesUnique = @{};
    [hashtable]$ProcessIDsByName   = @{};

    foreach ($processinfo in $ProcessInformation) {
        [string]$processName = $processinfo.Name.Replace('.exe', '');

        If ($null -ne $Process) {
            If (-Not ($Process.Contains($processName))) {
                continue;
            }
        }

        if ($ProcessList.ContainsKey($processName) -eq $FALSE) {
            $ProcessList.Add($processName, @{
                'ProcessList' = @{};
                'PerformanceData' = @{}
            });
        }

        $ProcessList[$processName]['ProcessList'].Add(
            [string]$processinfo.ProcessID, @{
                'Name' = $processinfo.Name;
                'ProcessId' = $processinfo.ProcessId;
                'Priority' = $processinfo.Priority;
                'PageFileUsage' = $processinfo.PageFileUsage;
                'ThreadCount' = $processinfo.ThreadCount;
                'KernelModeTime' = $processinfo.KernelModeTime;
                'UserModeTime' = $processinfo.UserModeTime;
                'WorkingSetSize' = $processinfo.WorkingSetSize;
                'CommandLine' = $processinfo.CommandLine;
            }
        );

        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'ThreadCount' -Process $processinfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'PageFileUsage' -Process $processinfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'KernelModeTime' -Process $processinfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'UserModeTime' -Process $processinfo;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'WorkingSetSize' -Process $processinfo;
    }

    foreach ($processinfo in $ProcessPerfDataList) {
        if ($processinfo.Name -eq '_Total' -Or $processinfo.Name -eq 'Idle') {
            continue;
        }

        If ($null -ne $Process) {
            If (-Not ($Process.Contains($processName))) {
                continue;
            }
        }

        [string]$processName = $processinfo.Name.Split('#')[0];
        [string]$ProcessId = $processinfo.IDProcess;

        if ($ProcessList.ContainsKey($processName) -eq $FALSE) {
            continue;
        }

        if ($ProcessList[$processName]['ProcessList'].ContainsKey($ProcessId) -eq $FALSE) {
            continue;
        }

        $ProcessList[$processName]['ProcessList'][$ProcessId].Add(
            'WorkingSetPrivate', $processinfo.WorkingSetPrivate
        );
        $ProcessList[$processName]['ProcessList'][$ProcessId].Add(
            'PercentProcessorTime', ($processinfo.PercentProcessorTime / $CPUCoreCount)
        );

        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'WorkingSetPrivate' -Process $process;
        if ($ProcessList[$processName]['PerformanceData'].ContainsKey('PercentProcessorTime') -eq $FALSE) {
            $ProcessList[$processName]['PerformanceData'].Add('PercentProcessorTime', ($processinfo.PercentProcessorTime / $CPUCoreCount));
        } else {
            $ProcessList[$processName]['PerformanceData']['PercentProcessorTime'] += ($processinfo.PercentProcessorTime / $CPUCoreCount);
        }
    }

    $ProcessData.Add('Process Count', $ProcessInformation.Count);
    $ProcessData.add('Processes', $ProcessList);
    
    return $ProcessData;
}