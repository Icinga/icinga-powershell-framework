<#
.SYNOPSIS
    Calls the PowerShell Garbage-Collector to force freeing memory
    in a more aggressive way. Also fixes an issue on older PowerShell
    versions on which the Garbage-Collector is not clearing memory
    properly
.DESCRIPTION
    Calls the PowerShell Garbage-Collector to force freeing memory
    in a more aggressive way. Also fixes an issue on older PowerShell
    versions on which the Garbage-Collector is not clearing memory
    properly
.PARAMETER ClearErrorStack
    Also clears the current error stack to free additional memory
.PARAMETER SmartGC
    Ensures that memory is not flushed whenever this function is called, but instead
    every 30 attempts this function is called to reduce CPU load. Only works for
    PowerShell sessions with "$Global:Icinga.Protected.ThreadName" being set
.EXAMPLE
    Optimize-IcingaForWindowsMemory;
.EXAMPLE
    Optimize-IcingaForWindowsMemory -ClearErrorStack;
.NOTES
    Clears memory used by PowerShell in a more aggressive way
#>
function Optimize-IcingaForWindowsMemory()
{
    param (
        [switch]$ClearErrorStack = $FALSE,
        [switch]$SmartGC         = $FALSE
    );

    if ([string]::IsNullOrEmpty($Global:Icinga.Protected.ThreadName) -eq $FALSE -And $SmartGC) {
        if ($Global:Icinga.Protected.GarbageCollector.ContainsKey($Global:Icinga.Protected.ThreadName) -eq $FALSE) {
            $Global:Icinga.Protected.GarbageCollector.Add($Global:Icinga.Protected.ThreadName, 0);

            return;
        } else {
            $Global:Icinga.Protected.GarbageCollector[$Global:Icinga.Protected.ThreadName] += 1;
        }

        if ($Global:Icinga.Protected.GarbageCollector[$Global:Icinga.Protected.ThreadName] -le 30) {
            return;
        }

        $Global:Icinga.Protected.GarbageCollector[$Global:Icinga.Protected.ThreadName] = 0;
    }

    # Clear all errors within our error stack
    if ($ClearErrorStack) {
        $Error.Clear();
    }

    # Force the full collection of memory being used
    [decimal]$MemoryConsumption = [System.GC]::GetTotalMemory('forcefullcollection');
    # Collect all generations of objects inside our memory and force the flushing of
    # objects
    [System.GC]::Collect([System.GC]::MaxGeneration, [System.GCCollectionMode]::Forced);
    # Collect the remaining memory for a before/after delta
    [decimal]$CollectedMemory   = [System.GC]::GetTotalMemory('forcefullcollection');
    # Just for debugging
    [decimal]$MemoryDelta       = $MemoryConsumption - $CollectedMemory;
    [bool]$Negate               = $FALSE;

    if ($MemoryDelta -lt 0) {
        $MemoryDelta = $MemoryDelta * -1;
        $Negate      = $TRUE;
    }

    $MemoryConsumptionMiB = Convert-Bytes -Value $MemoryConsumption -Unit 'MiB';
    $CollectedMemoryMiB   = Convert-Bytes -Value $CollectedMemory -Unit 'MiB';
    $MemoryDeltaMiB       = Convert-Bytes -Value $MemoryDelta -Unit 'MiB';

    # Print an optional debug message, allowing us to analyze memory behavior over time
    Write-IcingaDebugMessage `
        -Message 'Calling Icinga for Windows Garbage-Collector. Memory overview below (Before, After, Flushed/Added)' `
        -Objects @(
            ([string]::Format('{0} MiB', $MemoryConsumptionMiB.Value)),
            ([string]::Format('{0} MiB', $CollectedMemoryMiB.Value)),
            ([string]::Format('{1}{0} MiB', $MemoryDeltaMiB.Value, (&{ if ($Negate) { return '-'; } else { return ''; } })))
        );
}
