function Test-IcingaInterceptCounter()
{
    Write-IcingaConsoleNotice 'Testing for Microsoft SCOM Intercept Counters';

    [bool]$TestResult            = $TRUE;
    [array]$InterceptCounterList = @(
        'HKLM:\SYSTEM\CurrentControlSet\Services\Intercept CSM Filters\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\Intercept Injector\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\Intercept SyncAction Processing\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\InterceptCountersManager\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\InterceptCountersManager\Performance',
        'HKLM:\SYSTEM\CurrentControlSet\Services\Backup Exec\Performance'
    );

    foreach ($counter in $InterceptCounterList) {
        if (Test-Path -Path $counter) {
            $CounterState = Get-ItemProperty -Path $counter -Name 'Disable Performance Counters' -ErrorAction SilentlyContinue;

            if ($null -eq $CounterState -Or $CounterState.'Disable Performance Counters' -eq 0) {
                Write-IcingaTestOutput -Severity 'Failed' -Message ([string]::Format('Entry "{0}" is present on the system and the intercept counter is NOT disabled', $counter));
                $TestResult = $FALSE;
                continue;
            }

            Write-IcingaTestOutput -Severity 'Passed' -Message ([string]::Format('Entry "{0}" is present on the system and the intercept counter is disabled', $counter));
        } else {
           Write-IcingaTestOutput -Severity 'Passed' -Message ([string]::Format('Entry "{0}" is not present on the system', $counter));
        }
    }

    if ($TestResult -eq $FALSE) {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'One or more intercept counters exist on this system which are not disabled. Please take a look at https://icinga.com/docs/icinga-for-windows/latest/doc/knowledgebase/IWKB000016/ for further details';
    } else {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'There are either no intercept counters installed on your system or they are disabled. Monitoring of Performance Counters should work fine';
    }
}
