Import-Module $IncludeDir\provider\cpu;

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

    $ProcessInformation     = Get-WmiObject Win32_Process;
    $ProcessPerfDataList    = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process;
    $ProcessUniqueList      = Get-WmiObject Win32_Process | Select-Object name -unique;
    $CPUCoreCount           = Get-IcingaCPUCount;
    
    
    [hashtable]$ProcessData        = @{};
    [hashtable]$ProcessList        = @{};
    [hashtable]$ProcessNamesUnique = @{};
    [hashtable]$ProcessIDsByName   = @{};
    #$NumberOfCPUThreads = $Icinga2.System.NumberOfCPUThreads;

    foreach ($process in $ProcessInformation) {
        [string]$processName = $process.Name.Replace('.exe', '');

        if ($ProcessList.ContainsKey($processName) -eq $FALSE) {
            $ProcessList.Add($processName, @{
                'ProcessList' = @{};
                'PerformanceData' = @{}
            });
        }

        $ProcessList[$processName]['ProcessList'].Add(
            [string]$process.ProcessID, @{
                'Name' = $process.Name;
                'ProcessId' = $process.ProcessId;
                'Priority' = $process.Priority;
                'PageFileUsage' = $process.PageFileUsage;
                'ThreadCount' = $process.ThreadCount;
                'KernelModeTime' = $process.KernelModeTime;
                'UserModeTime' = $process.UserModeTime;
                'WorkingSetSize' = $process.WorkingSetSize;
                'CommandLine' = $process.CommandLine;
            }
        );

        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'ThreadCount' -Process $process;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'PageFileUsage' -Process $process;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'KernelModeTime' -Process $process;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'UserModeTime' -Process $process;
        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'WorkingSetSize' -Process $process;
    }

    foreach ($process in $ProcessPerfDataList) {
        if ($process.Name -eq '_Total' -Or $process.Name -eq 'Idle') {
            continue;
        }

        [string]$processName = $process.Name.Split('#')[0];
        [string]$ProcessId = $process.IDProcess;

        if ($ProcessList.ContainsKey($processName) -eq $FALSE) {
            Write-Host 'Unknown Process Name: ' $processName;
            continue;
        }

        if ($ProcessList[$processName]['ProcessList'].ContainsKey($ProcessId) -eq $FALSE) {
            Write-Host 'Unknown Process ID: ' $ProcessId;
            continue;
        }

        $ProcessList[$processName]['ProcessList'][$ProcessId].Add(
            'WorkingSetPrivate', $process.WorkingSetPrivate
        );
        $ProcessList[$processName]['ProcessList'][$ProcessId].Add(
            'PercentProcessorTime', ($process.PercentProcessorTime / $CPUCoreCount)
        );

        Add-IcingaProcessPerfData -ProcessList $ProcessList[$processName]['PerformanceData'] -ProcessKey 'WorkingSetPrivate' -Process $process;
        if ($ProcessList[$processName]['PerformanceData'].ContainsKey('PercentProcessorTime') -eq $FALSE) {
            $ProcessList[$processName]['PerformanceData'].Add('PercentProcessorTime', ($process.PercentProcessorTime / $CPUCoreCount));
        } else {
            $ProcessList[$processName]['PerformanceData']['PercentProcessorTime'] += ($process.PercentProcessorTime / $CPUCoreCount);
        }
    }

    $ProcessData.Add('Process Count', $ProcessInformation.Count);
    $ProcessData.add('Processes', $ProcessList);
    
    return $ProcessData;
    # Code Stolli below
    
    foreach ($NameID in $ProcessUniqueList.Name) {
        $ProcessIDsBasedOnName = (Get-WmiObject Win32_Process -Filter name="'${NameID}'").ProcessID;
        $ProcessIDsByName.Add($NameID,$ProcessIDsBasedOnName);
    }
    
    foreach ($id in $ProcessUniqueList) {
        $nameid = $id.name;
        $ProcessNamesUnique.Add(
            $id.Name.trim(".exe"), @{
                'processlist' = @{
                    $ProcessIDsByName.Item("$nameid") = "metadata";
                };
                'perfdata' = @{
                    'lawl' = 'lol';
                    'lel' = 'lel';
                    'lol' = 'eyooo';
                }
            }
        );
    }
    
    
    $ProcessData.Add('Process Count', $ProcessInformation.Count);
    $ProcessData.add('Processes', $ProcessNamesUnique);
    
    return $ProcessData;
}