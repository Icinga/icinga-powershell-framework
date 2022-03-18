function Set-IcingaForWindowsThreadAlive()
{
    param (
        [string]$ThreadName         = '',
        [string]$ThreadCmd          = '',
        $ThreadPool                 = $null,
        [hashtable]$ThreadArgs      = @{ },
        [switch]$Active             = $FALSE,
        [hashtable]$TerminateAction = @{ }
    );

    if ([string]::IsNullOrEmpty($ThreadName)) {
        return;
    }

    if ($Global:Icinga.Public.ThreadAliveHousekeeping.ContainsKey($ThreadName) -eq $FALSE) {
        if ($null -eq $ThreadPool) {
            return;
        }

        $Global:Icinga.Public.ThreadAliveHousekeeping.Add(
            $ThreadName,
            @{
                'LastSeen'        = [DateTime]::Now;
                'Command'         = $ThreadCmd;
                'Arguments'       = $ThreadArgs;
                'ThreadPool'      = $ThreadPool;
                'Active'          = [bool]$Active;
                'TerminateAction' = $TerminateAction;
            }
        );

        return;
    }

    $Global:Icinga.Public.ThreadAliveHousekeeping[$ThreadName].LastSeen        = [DateTime]::Now;
    $Global:Icinga.Public.ThreadAliveHousekeeping[$ThreadName].Active          = [bool]$Active;
    $Global:Icinga.Public.ThreadAliveHousekeeping[$ThreadName].TerminateAction = $TerminateAction;
}
