<#
.SYNOPSIS
   Displays all available instances for a provided Performance Counter
.DESCRIPTION
   Displays all available instances for a provided Performance Counter
.FUNCTIONALITY
   Displays all available instances for a provided Performance Counter
.PARAMETER Counter
   The name of the Performance Counter to fetch data for
.EXAMPLE
   PS>Show-IcingaPerformanceCounterInstances -Counter '\Processor(*)\% processor time';

   Name                           Value
    ----                           -----
    _Total                         \Processor(_Total)\% processor time
    0                              \Processor(0)\% processor time
    1                              \Processor(1)\% processor time
    2                              \Processor(2)\% processor time
    3                              \Processor(3)\% processor time
    ...
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Show-IcingaPerformanceCounterInstances()
{
    param (
        [string]$Counter
    );

    [hashtable]$Instances = @{};

    if ([string]::IsNullOrEmpty($Counter)) {
        Write-IcingaConsoleError 'Please enter a Performance Counter';
        return;
    }

    $PerfCounter  = New-IcingaPerformanceCounter -Counter $Counter -SkipWait $TRUE;

    foreach ($entry in $PerfCounter.Counters) {
        $Instances.Add(
            $entry.Instance,
            ($Counter.Replace('(*)', ([string]::Format('({0})', $entry.Instance))))
        );
    }

    if ($Instances.Count -eq 0) {
        Write-IcingaConsoleNotice `
            -Message 'No instances were found for Performance Counter "{0}". Please ensure the provided counter has instances and you are using "*" for the instance name.' `
            -Objects $Counter;

        return;
    }

    return (
        $Instances.GetEnumerator() | Sort-Object Name
    );
}
