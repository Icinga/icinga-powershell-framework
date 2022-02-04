function Show-IcingaRegisteredBackgroundDaemons()
{
    [array]$DaemonSummary  = @(
        'List of configured background daemons on this system:',
        ''
    );

    [hashtable]$DaemonList = Get-IcingaBackgroundDaemons;

    foreach ($daemon in $DaemonList.Keys) {

        $DaemonSummary    += $daemon;
        $DaemonSummary    += '-----------';
        $DaemonConfig      = $DaemonList[$daemon];

        [int]$MaxLength    = (Get-IcingaMaxTextLength -TextArray $DaemonConfig.Keys) - 1;
        [array]$DaemonData = @();

        foreach ($daemonArgument in $DaemonConfig.Keys) {
            $daemonValue = $DaemonConfig[$daemonArgument];
            $PrintName   = Add-IcingaWhiteSpaceToString -Text $daemonArgument -Length $MaxLength;
            $DaemonData += [string]::Format('{0} => {1}', $PrintName, $daemonValue);
        }

        if ($DaemonConfig.Count -eq 0) {
            $DaemonSummary += 'No arguments defined';
        }

        $DaemonSummary += $DaemonData | Sort-Object;
        $DaemonSummary += '';
    }

    if ($DaemonList.Count -eq 0) {
        $DaemonSummary += 'No background daemons configured';
        $DaemonSummary += '';
    }

    Write-Output $DaemonSummary;
}
