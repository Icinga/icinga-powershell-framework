function Enable-IcingaInterceptCounter()
{
    [array]$InterceptCounterList = @(
        'HKLM:\SYSTEM\CurrentControlSet\Services\Intercept CSM Filters\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\Intercept Injector\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\Intercept SyncAction Processing\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\InterceptCountersManager\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\InterceptCountersManager\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\Backup Exec\Performance'
    );

    foreach ($counter in $InterceptCounterList) {
        if (Test-Path $counter) {
            Write-IcingaConsoleNotice 'Enabling SCOM intercept counter "{0}"' -Objects $counter

            $CounterState = Get-ItemProperty -Path $counter -Name 'Disable Performance Counters' -ErrorAction SilentlyContinue;

            if ($null -eq $CounterState) {
                continue;
            }

            Set-ItemProperty -Path $counter -Name 'Disable Performance Counters' -Value 0;
        } else {
            Write-IcingaConsoleNotice 'SCOM intercept counter "{0}" not installed on the system' -Objects $counter
        }
    }
}
