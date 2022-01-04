function Split-IcingaVersion()
{
    param(
        [string]$Version
    );

    # TODO: Allow developers to adjust their code from mayor to major naming
    #       for the next releases and remove the mayor naming in the future
    if ([string]::IsNullOrEmpty($Version)) {
        return @{
            'Full'     = '';
            'Mayor'    = $null;
            'Major'    = $null;
            'Minor'    = $null;
            'Fixes'    = $null;
            'Snapshot' = $null;
        }
    }

    [array]$IcingaVersion = $Version.Split('.');
    $Snapshot             = $null;

    if ([string]::IsNullOrEmpty($IcingaVersion[3]) -eq $FALSE) {
        $Snapshot = [int]$IcingaVersion[3];
    }

    return @{
        'Full'     = $Version;
        'Mayor'    = [int]$IcingaVersion[0];
        'Major'    = [int]$IcingaVersion[0];
        'Minor'    = [int]$IcingaVersion[1];
        'Fixes'    = [int]$IcingaVersion[2];
        'Snapshot' = $Snapshot;
    }
}
