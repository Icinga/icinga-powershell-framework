function Stop-IcingaJEAProcess()
{
    param (
        [string]$JeaPid = $null
    );

    if ([string]::IsNullOrEmpty($JeaPid)) {
        [string]$JeaPid = Get-IcingaJEAServicePid;
    }

    if ([string]::IsNullOrEmpty($JeaPid)) {
        return;
    }

    if ($JeaPid -eq '0' -Or $JeaPid -eq 0) {
        return;
    }

    $JeaPowerShellProcess = Get-Process -Id $JeaPid -ErrorAction SilentlyContinue;
    if ($null -eq $JeaPowerShellProcess) {
        return;
    }

    if ($JeaPowerShellProcess.ProcessName -ne 'wsmprovhost') {
        return;
    }

    try {
        Stop-Process -Id $JeaPid -Force -ErrorAction Stop;
    } catch {
        Write-IcingaConsoleError 'Unable to stop the JEA process "wsmprovhost" caused by the following error: "{0}".' -Objects $_.Exception.Message;
    }
}
