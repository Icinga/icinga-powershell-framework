function New-IcingaCheckSchedulerEnvironment()
{
    # Legacy code
    $IcingaDaemonData.IcingaThreadContent.Add('Scheduler', @{ });

    if ($null -eq $global:Icinga) {
        $global:Icinga = @{};
    }

    $global:Icinga.Add('CheckResults', @());
    $global:Icinga.Add('PerfData', @());
}
