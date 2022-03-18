function Get-IcingaNextRESTApiThreadId()
{
    # Improve our thread management by distributing new REST requests to a non-active thread
    [array]$ConfiguredThreads = $Global:Icinga.Public.ThreadAliveHousekeeping.Keys;

    foreach ($thread in $ConfiguredThreads) {
        if ($thread.ToLower() -NotLike 'Start-IcingaForWindowsRESTThread::New-IcingaForWindowsRESTThread::CheckThread::*') {
            continue;
        }

        $ThreadConfig = $Global:Icinga.Public.ThreadAliveHousekeeping[$thread];

        # If our thread is busy, skip this one and check for another one
        if ($ThreadConfig.Active) {
            continue;
        }

        $ThreadIndex = $thread.Replace('Start-IcingaForWindowsRESTThread::New-IcingaForWindowsRESTThread::CheckThread::', '');

        if (Test-Numeric $ThreadIndex) {
            $Global:Icinga.Public.Daemons.RESTApi.LastThreadId = [int]$ThreadIndex;
            return ([int]$ThreadIndex)
        }
    }

    # In case we are not having any spare thread left, distribute the thread to the next thread in our list
    [int]$ConcurrentThreads = $Global:Icinga.Public.Daemons.RESTApi.TotalThreads - 1;
    [int]$LastThreadId      = $Global:Icinga.Public.Daemons.RESTApi.LastThreadId + 1;

    if ($LastThreadId -gt $ConcurrentThreads) {
        $LastThreadId = 0;
    }

    $Global:Icinga.Public.Daemons.RESTApi.LastThreadId = $LastThreadId;

    return $LastThreadId;
}
