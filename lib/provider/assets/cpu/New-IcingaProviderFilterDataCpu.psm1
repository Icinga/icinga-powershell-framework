<#
.ROLE
    Query
#>

function New-IcingaProviderFilterDataCpu()
{
    param (
        [switch]$Limit100Percent = $FALSE,
        [switch]$IncludeDetails  = $FALSE
    );

    # TODO: Cleanup this mess
    $CpuData                       = New-IcingaProviderObject -Name 'Cpu';
    $CpuCounter                    = New-IcingaPerformanceCounterArray '\Processor(*)\% Processor Time';
    $CounterStructure              = New-IcingaPerformanceCounterStructure -CounterCategory 'Processor' -PerformanceCounterHash $CpuCounter;
    [int]$TotalCpuThreads          = 0;
    [decimal]$TotalCpuLoad         = 0;
    [int]$SocketCount              = 0;
    [hashtable]$SocketList         = @{ };
    # Store some general data about the CPU sockets and cores. As we moved back to
    # \Processor(*)\% Processor Time, we need to manually try to map cores to sockets
    # Remove ony entry from the counter list, which is not a core but the total load entry
    [int]$NumberOfThreadsPerSocket = ($CpuCounter.Values.Keys.Count - 1) / $Global:Icinga.Protected.CPUSockets;
    [int]$CurrentSocket            = 0;
    [int]$CurrentThread            = 0;
    [array]$SortedCoreList         = $CounterStructure.Keys | Sort-Object { [int]($_ -replace '^\D+', ''); };

    foreach ($currentcore in $SortedCoreList) {
        [string]$CoreId = $currentcore.Trim();

        # We will handle the _Total entry ourselves later
        if ($CoreId -eq '_Total') {
            continue;
        }

        [string]$SocketName = [string]::Format('Socket #{0}', $CurrentSocket);

        $CurrentThread += 1;
        if ($CurrentThread -ge $NumberOfThreadsPerSocket) {
            $CurrentSocket += 1;
            $CurrentThread = 0;
        }

        if ($SocketList.ContainsKey($SocketName) -eq $FALSE) {
            $SocketList.Add(
                $SocketName,
                @{
                    'ThreadCount' = 0;
                    'TotalLoad'   = 0;
                }
            );
        }

        if ((Test-PSCustomObjectMember -PSObject $CpuData.Metrics -Name $SocketName) -eq $FALSE) {
            $CpuData.Metrics | Add-Member -MemberType NoteProperty -Name $SocketName -Value (New-Object PSCustomObject);
        }

        [decimal]$CoreLoad = $CounterStructure[$CoreId]['% Processor Time'].value;

        if ($Limit100Percent) {
            if ($CoreLoad -gt 100) {
                $CoreLoad = 100;
            }
        }

        $CpuData.Metrics.$SocketName             | Add-Member -MemberType NoteProperty -Name $CoreId -Value $CoreLoad;
        $CpuData.MetricsOverTime.MetricContainer | Add-Member -MemberType NoteProperty -Name $SocketName -Value $null -Force;

        $SocketList[$SocketName].ThreadCount += 1;
        $SocketList[$SocketName].TotalLoad   += $CoreLoad;
    }

    $CpuData.Metadata | Add-Member -MemberType NoteProperty -Name 'Sockets' -Value (New-Object PSCustomObject);

    foreach ($entry in $SocketList.Keys) {
        $SocketList[$entry].TotalLoad = $SocketList[$entry].TotalLoad / $SocketList[$entry].ThreadCount;
        $TotalCpuLoad                += $SocketList[$entry].TotalLoad;
        $TotalCpuThreads             += $SocketList[$entry].ThreadCount;
        $SocketCount                 += 1;

        $CpuData.Metadata.Sockets        | Add-Member -MemberType NoteProperty -Name $entry    -Value (New-Object PSCustomObject);
        $CpuData.Metadata.Sockets.$entry | Add-Member -MemberType NoteProperty -Name 'Threads' -Value $SocketList[$entry].ThreadCount;
        $CpuData.Metrics.$entry          | Add-Member -MemberType NoteProperty -Name 'Total'   -Value $SocketList[$entry].TotalLoad;
    }

    $CpuData.Metadata | Add-Member -MemberType NoteProperty -Name 'TotalLoad'    -Value ($TotalCpuLoad / $SocketCount);
    $CpuData.Metadata | Add-Member -MemberType NoteProperty -Name 'TotalLoadSum' -Value $TotalCpuLoad;
    $CpuData.Metadata | Add-Member -MemberType NoteProperty -Name 'TotalThreads' -Value $TotalCpuThreads;
    $CpuData.Metadata | Add-Member -MemberType NoteProperty -Name 'CoreDigits'   -Value ([string]$TotalCpuThreads).Length;
    $CpuData.Metadata | Add-Member -MemberType NoteProperty -Name 'CoreDetails'  -Value (New-Object PSCustomObject);

    if ($IncludeDetails) {
        [array]$CPUCIMData = Get-IcingaWindowsInformation Win32_Processor;

        foreach ($cpu in $CPUCIMData) {
            if ((Test-PSCustomObjectMember -PSObject $CpuData.Metadata.CoreDetails -Name $cpu.DeviceID) -eq $FALSE) {
                $CpuData.Metadata.CoreDetails | Add-Member -MemberType NoteProperty -Name $cpu.DeviceID -Value (New-Object PSCustomObject);
            }
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'Architecture'      -Value $cpu.Architecture;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'ProcessorType'     -Value $cpu.ProcessorType;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'StatusInfo'        -Value $cpu.StatusInfo;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'Family'            -Value $cpu.Family;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'CurrentVoltage'    -Value $cpu.CurrentVoltage;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'L3CacheSize'       -Value $cpu.L3CacheSize;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'L2CacheSize'       -Value $cpu.L2CacheSize;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'L2CacheSpeed'      -Value $cpu.L2CacheSpeed;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'VoltageCaps'       -Value $cpu.VoltageCaps;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'CurrentClockSpeed' -Value $cpu.CurrentClockSpeed;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'Caption'           -Value $cpu.Caption;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'Name'              -Value $cpu.Name;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'SerialNumber'      -Value $cpu.SerialNumber;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'Manufacturer'      -Value $cpu.Manufacturer;
            $CpuData.Metadata.CoreDetails.($cpu.DeviceID) | Add-Member -MemberType NoteProperty -Name 'AddressWidth'      -Value $cpu.AddressWidth;
        }
    }

    return $CpuData;
}
