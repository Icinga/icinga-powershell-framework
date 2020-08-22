<#
.SYNOPSIS
    Prints the description of a Performance Counter if available on the system
.DESCRIPTION
    Prints the description of a Performance Counter if available on the system
.FUNCTIONALITY
    Prints the description of a Performance Counter if available on the system
.EXAMPLE
    PS>Show-IcingaPerformanceCounterHelp '\Processor(*)\% processor time';

    % Processor Time is the percentage of elapsed time that the processor spends to execute a non-Idle thread. It is calculated by measuring the percentage of time that the processor spends executing the idle thread and then subtracting that value from 100%. (Each processor has an idle thread that consumes cycles when no other threads are ready to run). This counter is the primary indicator of processor activity, and displays the average percentage of busy time observed during the sample interval. It should be noted that the accounting calculation of whether the processor is idle is performed at an internal sampling interval of the system clock (10ms). On todays fast processors, % Processor Time can therefore underestimate the processor utilization as the processor may be spending a lot of time servicing threads between the system clock sampling interval. Workload based timer applications are one example  of applications  which are more likely to be measured inaccurately as timers are signaled just after the sample is taken.
.EXAMPLE
    PS>Show-IcingaPerformanceCounterHelp '\Memory\system code total bytes';

    System Code Total Bytes is the size, in bytes, of the pageable operating system code currently mapped into the system virtual address space. This value is calculated by summing the bytes in Ntoskrnl.exe, Hal.dll, the boot drivers, and file systems loaded by Ntldr/osloader.  This counter does not include code that must remain in physical memory and cannot be written to disk. This counter displays the last observed value only; it is not an average.
.PARAMETER Counter
    The full path to the Performance Counter to lookup.
.INPUTS
    System.String
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>
function Show-IcingaPerformanceCounterHelp()
{
    param (
        [string]$Counter = ''
    );

    if ([string]::IsNullOrEmpty($Counter)) {
        Write-IcingaConsoleError 'Please enter a Performance Counter';
        return;
    }

    # Create a Performance Counter array which is easier to access later on and skip possible waits
    $PerfCounter       = New-IcingaPerformanceCounterArray -Counter $Counter -SkipWait $TRUE;
    [string]$HelpText  = '';
    [string]$ErrorText = '';

    if ($PerfCounter.ContainsKey($Counter)) {
        # Handle counters without instances, like '\Memory\system code total bytes'
        $HelpText  = $PerfCounter[$Counter].help;
        $ErrorText = $PerfCounter[$Counter].error;

        if ([string]::IsNullOrEmpty($HelpText)) {
            # Handle counters with instances, like '\Processor(*)\% processor time'
            $CounterObject = $PerfCounter[$Counter].GetEnumerator() | Select-Object -First 1;
            $CounterData   = $CounterObject.Value;
            $HelpText      = $CounterData.help;
            if ([string]::IsNullOrEmpty($ErrorText)) {
                $ErrorText = $CounterData.error;
            }
        }
    }
    
    if ([string]::IsNullOrEmpty($HelpText) -eq $FALSE) {
        return $HelpText;
    }

    Write-IcingaConsoleError `
        -Message 'Help context for the Performance Counter "{0}" could not be loaded or was not found. Error context if available: "{1}"' `
        -Objects $Counter, $ErrorText;
}
