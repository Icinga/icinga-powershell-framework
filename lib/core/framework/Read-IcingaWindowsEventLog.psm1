function Read-IcingaWindowsEventLog()
{
    param (
        [string]$LogName = 'Application',
        [array]$Source   = @(),
        [int]$MaxEntries = 500
    );

    if ([string]::IsNullOrEmpty($LogName)) {
        Write-IcingaConsoleError 'You have to specify a log to read from';
        return;
    }

    $LastEvent   = $null;
    $LastMessage = $null;
    $LastId      = $null;
    $MaxEvents   = 40000;

    while ($TRUE) {
        [array]$IcingaEvents    = Get-WinEvent -LogName $LogName -MaxEvents $MaxEvents -ErrorAction Stop;
        [int]$CurrentIndex      = $MaxEntries;
        [array]$CollectedEvents = @();

        foreach ($event in $IcingaEvents) {

            if ($CurrentIndex -eq 0) {
                break;
            }

            if ($Source.Count -ne 0 -And $Source -NotContains $event.ProviderName) {
                continue;
            }

            $CurrentIndex -= 1;

            if ($null -ne $LastEvent -And $event.TimeCreated -lt $LastEvent) {
                $MaxEvents = 500;
                break;
            }

            if ($event.TimeCreated -eq $LastEvent -And (Get-StringSha1 -Content $event.Message) -eq $LastMessage -And $event.Id -eq $LastId) {
                $MaxEvents = 500;
                break;
            }

            $CollectedEvents += $event;
        }

        $CollectedEvents = $CollectedEvents | Sort-Object { $_.TimeCreated };

        foreach ($event in $CollectedEvents) {

            $ForeColor   = 'White';

            if ($event.Level -eq 3) { # Warning
                $ForeColor = 'DarkYellow';
            } elseif ($event.Level -eq 2) { # Error
                $ForeColor = 'Red';
            }

            $LastMessage = (Get-StringSha1 -Content $event.Message);
            $LastId      = $event.Id;
            $LastEvent   = [DateTime]$event.TimeCreated;

            Write-IcingaConsolePlain -Message '[{0}] {1}' -Objects $event.TimeCreated, $event.Message -ForeColor $ForeColor;
        }

        Start-Sleep -Seconds 1;
        # Force Icinga for Windows Garbage Collection
        Optimize-IcingaForWindowsMemory -ClearErrorStack;
    }
}
