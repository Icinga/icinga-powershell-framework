function Get-IcingaNextRESTApiThreadId()
{
    [int]$ConcurrentThreads = $IcingaDaemonData.IcingaThreadContent.RESTApi.TotalThreads - 1;
    [int]$LastThreadId      = $IcingaDaemonData.IcingaThreadContent.RESTApi.LastThreadId + 1;

    if ($LastThreadId -gt $ConcurrentThreads) {
        $LastThreadId = 0;
    }

    $IcingaDaemonData.IcingaThreadContent.RESTApi.LastThreadId = $LastThreadId;

    return $LastThreadId;
}
