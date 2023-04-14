function Get-IcingaWindowsServiceStatus()
{
    param (
        [string]$Service = '',
        [switch]$Force   = $FALSE
    );

    if ($Service -eq 'icinga2' -Or $Service -eq 'icingapowershell') {
        if ($Service -eq 'icinga2') {
            if ([string]::IsNullOrEmpty($Global:Icinga.Protected.IcingaServiceState) -eq $FALSE) {
                if ($Global:Icinga.Protected.ServiceRestartLock -And $Force -eq $FALSE) {
                    return @{
                        'Status'      = $Global:Icinga.Protected.IcingaServiceState;
                        'Present'     = $TRUE;
                        'Name'        = $Service;
                        'DisplayName' = $Service;
                    };
                }
            }
        } elseif ($Service -eq 'icingapowershell') {
            if ([string]::IsNullOrEmpty($Global:Icinga.Protected.IfWServiceState) -eq $FALSE) {
                if ($Global:Icinga.Protected.ServiceRestartLock -And $Force -eq $FALSE) {
                    return @{
                        'Status'      = $Global:Icinga.Protected.IfWServiceState;
                        'Present'     = $TRUE;
                        'Name'        = $Service;
                        'DisplayName' = $Service;
                    };
                }
            }
        }
    }

    $ServiceData = Invoke-IcingaWindowsScheduledTask -JobType 'GetWindowsService' -ObjectName $Service;

    if ($ServiceData.Service.Installed -eq $FALSE) {
        Write-IcingaConsoleError $ServiceData.ErrMsg;
        return @{
            'Status'      = '';
            'Present'     = $FALSE;
            'Name'        = 'Unknown';
            'DisplayName' = 'Unknown';
        };
    }

    if ($Service -eq 'icinga2') {
        $Global:Icinga.Protected.IcingaServiceState = $ServiceData.Service.Status;
    } elseif ($Service -eq 'icingapowershell') {
        $Global:Icinga.Protected.IfWServiceState = $ServiceData.Service.Status;
    }

    return $ServiceData.Service;
}
