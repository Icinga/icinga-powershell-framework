function Read-IcingaAgentLogFile()
{
    param (
        [array]$Include = @(),
        [array]$Exclude = @()
    );

    if ((Test-IcingaAgentFeatureEnabled -Feature 'windowseventlog') -And ([version](Get-IcingaAgentVersion).Full) -ge (New-IcingaVersionObject -Version '2.13.0')) {

        # Icinga 2.13.0 and beyond will log directly into the EventLog
        Read-IcingaWindowsEventLog -LogName 'Application' -Source 'Icinga 2' -MaxEntries 500 -Include $Include -Exclude $Exclude;
    } else {
        $Logfile = Join-Path -Path (Get-IcingaAgentLogDirectory) -ChildPath 'icinga2.log';
        if ((Test-Path $Logfile) -eq $FALSE) {
            Write-IcingaConsoleError 'Icinga 2 logfile not present. Unable to load it';
            return;
        }

        Get-Content -Path $Logfile -Tail 20 -Wait -Encoding 'UTF8';
    }
}
