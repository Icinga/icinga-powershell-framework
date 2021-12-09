function Invoke-IcingaInternalServiceCall()
{
    param (
        [string]$Command  = '',
        [array]$Arguments = @()
    );

    # If our Framework is running as daemon, never call our api
    if ($Global:Icinga.Protected.RunAsDaemon) {
        return;
    }

    # If the API forward feature is disabled, do nothing
    if ((Get-IcingaFrameworkApiChecks) -eq $FALSE) {
        return;
    }

    # Test our Icinga for Windows service. If the service is not installed or not running, execute the plugin locally
    $IcingaForWindowsService = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue);

    if ($null -eq $IcingaForWindowsService -Or $IcingaForWindowsService.Status -ne 'Running') {
        return;
    }

    # In case the REST-Api module ist not configured, do nothing
    $BackgroundDaemons = Get-IcingaBackgroundDaemons;

    if ($null -eq $BackgroundDaemons -Or $BackgroundDaemons.ContainsKey('Start-IcingaWindowsRESTApi') -eq $FALSE) {
        return;
    }

    $RestApiPort  = 5668;
    [int]$Timeout = 30;
    $Daemon       = $BackgroundDaemons['Start-IcingaWindowsRESTApi'];

    # Fetch our deamon configuration
    if ($Daemon.ContainsKey('-Port')) {
        $RestApiPort = $Daemon['-Port'];
    } elseif ($Daemon.ContainsKey('Port')) {
        $RestApiPort = $Daemon['Port'];
    }
    if ($Daemon.ContainsKey('-Timeout')) {
        $Timeout = $Daemon['-Timeout'];
    } elseif ($Daemon.ContainsKey('Timeout')) {
        $Timeout = $Daemon['Timeout'];
    }

    Set-IcingaTLSVersion;
    Enable-IcingaUntrustedCertificateValidation -SuppressMessages;

    [hashtable]$CommandArguments = @{ };
    [int]$ArgumentIndex          = 0;

    # Resolve our array arguments provided by $args and build proper check arguments
    while ($ArgumentIndex -lt $Arguments.Count) {
        $Value                 = $Arguments[$ArgumentIndex];
        [string]$Argument      = [string]$Value;
        $ArgumentValue         = $null;

        if ($Value[0] -eq '-') {
            if (($ArgumentIndex + 1) -lt $Arguments.Count) {
                [string]$NextValue = $Arguments[$ArgumentIndex + 1];
                if ($NextValue[0] -eq '-') {
                    $ArgumentValue = $TRUE;
                } else {
                    $ArgumentValue = $Arguments[$ArgumentIndex + 1];
                }
            } else {
                $ArgumentValue = $TRUE;
            }
        } else {
            $ArgumentIndex += 1;
            continue;
        }

        $Argument = $Argument.Replace('-', '');

        $CommandArguments.Add($Argument, $ArgumentValue);
        $ArgumentIndex += 1;
    }

    # Now queue the check inside our REST-Api
    try {
        $ApiResult = Invoke-WebRequest -Method POST -UseBasicParsing -Uri ([string]::Format('https://localhost:{0}/v1/checker?command={1}', $RestApiPort, $Command)) -Body (ConvertTo-JsonUTF8Bytes -InputObject $CommandArguments -Depth 100 -Compress) -ContentType 'application/json' -TimeoutSec $Timeout;
    } catch {
        # Fallback to execute plugin locally
        Write-IcingaEventMessage -Namespace 'Framework' -EventId 1553 -ExceptionObject $_ -Objects $Command, $CommandArguments;
        return;
    }

    # Resolve our result from the API
    $IcingaResult = ConvertFrom-JsonUTF8 -InputObject $ApiResult.Content;
    $IcingaCR     = '';

    # In case we didn't receive a check result, fallback to local execution
    if ([string]::IsNullOrEmpty($IcingaResult.$Command.checkresult)) {
        Write-IcingaEventMessage -Namespace 'Framework' -EventId 1553 -Objects 'The check result for the executed command was empty', $Command, $CommandArguments;
        return;
    }

    if ([string]::IsNullOrEmpty($IcingaResult.$Command.exitcode)) {
        Write-IcingaEventMessage -Namespace 'Framework' -EventId 1553 -Objects 'The check result for the executed command was empty', $Command, $CommandArguments;
        return;
    }

    $IcingaCR = ($IcingaResult.$Command.checkresult.Replace("`r`n", "`n"));

    if ($IcingaResult.$Command.perfdata.Count -ne 0) {
        $IcingaCR += ' | ';
        foreach ($perfdata in $IcingaResult.$Command.perfdata) {
            $IcingaCR += $perfdata;
        }
    }

    # Print our response and exit with the provide exit code
    Write-IcingaConsolePlain $IcingaCR;
    exit $IcingaResult.$Command.exitcode;
}
