function Start-IcingaServiceCheckTask()
{
    param (
        $CheckId,
        $CheckCommand,
        $Arguments,
        $Interval,
        $TimeIndexes
    );

    New-IcingaThreadInstance -Name $CheckId -ThreadPool (Get-IcingaThreadPool -Name 'ServiceCheckPool') -Command 'Add-IcingaServiceCheckTask' -CmdParameters @{
        'CheckCommand' = $CheckCommand;
        'Arguments'    = $Arguments;
        'Interval'     = $Interval;
        'TimeIndexes'  = $TimeIndexes
        'CheckId'      = $CheckId;
    } -Start;
}
