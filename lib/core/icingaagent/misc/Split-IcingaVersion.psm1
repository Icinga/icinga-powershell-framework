function Split-IcingaVersion()
{
    param(
        [string]$Version
    );

    if ([string]::IsNullOrEmpty($Version)) {
        return @{
            'Full'     = '';
            'Mayor'    = $null;
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
        'Minor'    = [int]$IcingaVersion[1];
        'Fixes'    = [int]$IcingaVersion[2];
        'Snapshot' = $Snapshot;
    }
}
