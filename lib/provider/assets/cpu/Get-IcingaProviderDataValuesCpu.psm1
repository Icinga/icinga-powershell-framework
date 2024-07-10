function Get-IcingaProviderDataValuesCpu()
{
    param (
        [array]$IncludeFilter      = @(),
        [array]$ExcludeFilter      = @(),
        [hashtable]$ProviderFilter = @(),
        [switch]$IncludeDetails    = $FALSE
    );

    $CpuData                 = New-IcingaProviderObject -Name 'Cpu';
    [hashtable]$FilterObject = Get-IcingaProviderFilterData -ProviderName 'Cpu' -ProviderFilter $ProviderFilter;

    $CpuData.Metrics         = $FilterObject.Cpu.Query.Metrics;
    $CpuData.MetricsOverTime = $FilterObject.Cpu.Query.MetricsOverTime;
    $CpuData.Metadata        = $FilterObject.Cpu.Query.Metadata;

    $FilterObject = $null;

    return $CpuData;
}
