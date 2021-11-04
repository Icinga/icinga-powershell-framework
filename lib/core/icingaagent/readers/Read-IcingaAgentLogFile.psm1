function Read-IcingaAgentLogFile()
{
    if ((Test-IcingaAgentFeatureEnabled -Feature 'windowseventlog') -And ([version](Get-IcingaAgentVersion).Full) -ge (New-IcingaVersionObject -Version '2.13.0')) {

        # Icinga 2.13.0 and beyond will log directly into the EventLog

        $LastEvent   = $null;
        $LastMessage = $null;
        $LastId      = $null;

        while ($TRUE) {
            $IcingaEvents = Get-WinEvent -LogName Application -MaxEvents 500 -ErrorAction Stop | Sort-Object { $_.TimeCreated };

            foreach ($event in $IcingaEvents) {

                if ($event.ProviderName -ne 'Icinga 2') {
                    continue;
                }

                if ($null -ne $LastEvent -And $event.TimeCreated -lt $LastEvent) {
                    continue;
                }

                if ($event.TimeCreated -eq $LastEvent -And (Get-StringSha1 -Content $event.Message) -eq $LastMessage -And $event.Id -eq $LastId) {
                    continue;
                }

                $LastEvent   = [DateTime]$event.TimeCreated;
                $LastMessage = (Get-StringSha1 -Content $event.Message);
                $LastId      = $event.Id;
                $ForeColor   = 'White';

                if ($event.Level -eq 3) { # Warning
                    $ForeColor = 'DarkYellow';
                } elseif ($event.Level -eq 2) { # Error
                    $ForeColor = 'Red';
                }

                Write-IcingaConsolePlain -Message '[{0}] {1}' -Objects $event.TimeCreated, $event.Message -ForeColor $ForeColor;
            }

            Start-Sleep -Seconds 1;
        }
    } else {
        $Logfile = Join-Path -Path (Get-IcingaAgentLogDirectory) -ChildPath 'icinga2.log';
        if ((Test-Path $Logfile) -eq $FALSE) {
            Write-IcingaConsoleError 'Icinga 2 logfile not present. Unable to load it';
            return;
        }

        Get-Content -Path $Logfile -Tail 20 -Wait;
    }
}
