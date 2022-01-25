function Get-IcingaNextRESTApiThreadId()
{
    [int]$ConcurrentThreads = $Global:Icinga.Public.Daemons.RESTApi.TotalThreads - 1;
    [int]$LastThreadId      = $Global:Icinga.Public.Daemons.RESTApi.LastThreadId + 1;

    if ($LastThreadId -gt $ConcurrentThreads) {
        $LastThreadId = 0;
    }

    $Global:Icinga.Public.Daemons.RESTApi.LastThreadId = $LastThreadId;

    return $LastThreadId;
}
