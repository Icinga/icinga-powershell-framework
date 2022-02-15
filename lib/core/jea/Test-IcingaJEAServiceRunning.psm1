function Test-IcingaJEAServiceRunning()
{
    param (
        [string]$JeaPid = $null
    );

    if ([string]::IsNullOrEmpty($JeaPid)) {
        [string]$JeaPid = Get-IcingaJEAServicePid;
    }

    if ([string]::IsNullOrEmpty($JeaPid)) {
        return $FALSE;
    }

    if ($JeaPid -eq '0' -Or $JeaPid -eq 0) {
        return $FALSE;
    }

    $JeaPowerShellProcess = Get-Process -Id $JeaPid -ErrorAction SilentlyContinue;
    if ($null -eq $JeaPowerShellProcess) {
        return $FALSE;
    }

    if ($JeaPowerShellProcess.ProcessName -ne 'wsmprovhost') {
        return $FALSE;
    }

    return $TRUE;
}
