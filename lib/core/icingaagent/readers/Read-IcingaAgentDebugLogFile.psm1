function Read-IcingaAgentDebugLogFile()
{
    $Logfile = Join-Path -Path (Get-IcingaAgentLogDirectory) -ChildPath 'debug.log';
    if ((Test-Path $Logfile) -eq $FALSE) {
        Write-IcingaConsoleError 'Icinga 2 debug logfile not present. Unable to load it';
        return;
    }

    Get-Content -Path $Logfile -Tail 20 -Wait;
}
