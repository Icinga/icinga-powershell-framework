function Read-IcingaAgentLogFile()
{
    $Logfile = Join-Path -Path (Get-IcingaAgentLogDirectory) -ChildPath 'icinga2.log';
    if ((Test-Path $Logfile) -eq $FALSE) {
        Write-Host 'Icinga 2 logfile not present. Unable to load it';
        return;
    }

    Get-Content -Path $Logfile -Tail 20 -Wait;
}
