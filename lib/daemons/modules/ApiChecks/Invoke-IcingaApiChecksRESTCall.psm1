function Invoke-IcingaApiChecksRESTCall()
{
    param (
        [Hashtable]$Request    = @{ },
        [Hashtable]$Connection = @{ },
        [string]$ApiVersion    = $null
    );

    [Hashtable]$ContentResponse = @{ };

    # Short our call
    $CheckerAliases = $Global:Icinga.Public.Daemons.RESTApi.CommandAliases.checker;
    $CheckConfig    = $Request.Body;
    [int]$ExitCode  = 3; #Unknown

    # Check if there are an inventory aliases configured
    # This should be maintained by the developer and not occur
    # anyway
    if ($null -eq $CheckerAliases) {
        $CheckerAliases = @{ };
    }

    if ((Get-IcingaRESTHeaderValue -Request $Request -Header 'Content-Type') -ne 'application/json' -And $Request.Method -eq 'POST') {
        Send-IcingaTCPClientMessage -Message (
            New-IcingaTCPClientRESTMessage `
                -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Bad Request') `
                -ContentBody 'This API endpoint does only accept "application/json" as content type over POST.'
        ) -Stream $Connection.Stream;

        return;
    }

    # Our namespace to include inventory packages is 'include' over the api
    # Everything else will be dropped for the moment
    if ($Request.RequestArguments.ContainsKey('list')) {

        Add-IcingaHashtableItem `
            -Hashtable $ContentResponse `
            -Key 'Commands' `
            -Value $CheckerAliases | Out-Null;

    } elseif ($Request.RequestArguments.ContainsKey('command')) {
        [string]$ExecuteCommand = $null;

        foreach ($element in $CheckerAliases.Keys) {
            if ($Request.RequestArguments.command -Contains $element) {
                $ExecuteCommand = $CheckerAliases[$element];
                # We only support to execute one check per call
                # No need to loop through everything
                break;
            }
        }

        if ([string]::IsNullOrEmpty($ExecuteCommand)) {
            [string]$ExecuteCommand = $Request.RequestArguments.command;
        }

        if ((Test-IcingaRESTApiCommand -Command $ExecuteCommand -Endpoint 'apichecks') -eq $FALSE) {
            Send-IcingaTCPClientMessage -Message (
                New-IcingaTCPClientRESTMessage `
                    -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Forbidden') `
                    -ContentBody ([string]::Format('The command "{0}" you are trying to execute over this REST-Api endpoint "apichecks" is not whitelisted for remote execution.', $ExecuteCommand))
            ) -Stream $Connection.Stream;

            return;
        }

        Write-IcingaDebugMessage -Message ('Executing API check for command: ' + $ExecuteCommand);

        if ([string]::IsNullOrEmpty($CheckConfig) -eq $FALSE -And $Request.Method -eq 'POST') {
            # Convert our JSON config for checks to a PSCustomObject
            $PSArguments = ConvertFrom-Json -InputObject $CheckConfig;

            # For executing the checks, we will require the data as
            # hashtable, so declare it here
            [hashtable]$Arguments = @{ };

            # Now convert our custom object by Key<->Value to
            # a valid hashtable, allowing us to parse arguments
            # to our check command
            $PSArguments.PSObject.Properties | ForEach-Object {
                Add-IcingaHashtableItem `
                    -Hashtable $Arguments `
                    -Key $_.Name `
                    -Value $_.Value | Out-Null;
            };

            [int]$ExitCode = & $ExecuteCommand @Arguments;
        } elseif ($Request.Method -eq 'GET') {
            [int]$ExitCode = & $ExecuteCommand;
        } else {
            Send-IcingaTCPClientMessage -Message (
                New-IcingaTCPClientRESTMessage `
                    -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.Ok) `
                    -ContentBody @{ 'message' = 'This API endpoint does only accept GET and POST methods for requests.' }
            ) -Stream $Connection.Stream;

            return;
        }

        # Once the check is executed, the plugin output and the performance data are stored
        # within a special cache map we can use for accessing
        $CheckResult     = Get-IcingaCheckSchedulerPluginOutput;
        [array]$PerfData = Get-IcingaCheckSchedulerPerfData;

        # Ensure our PerfData variable is always an array
        if ($null -eq $PerfData -Or $PerfData.Count -eq 0) {
            [array]$PerfData = @();
        }

        # Free our memory again
        Clear-IcingaCheckSchedulerEnvironment -ClearCheckData;

        Write-IcingaDebugMessage -Message 'Check Executed. Result below' -Objects $ExecuteCommand, $CheckResult, $PerfData, $ExitCode;

        Add-IcingaHashtableItem `
            -Hashtable $ContentResponse `
            -Key $ExecuteCommand `
            -Value @{
                'exitcode'    = $ExitCode;
                'checkresult' = $CheckResult;
                'perfdata'    = $PerfData;
            } | Out-Null;
    }

    if ($ContentResponse.Count -eq 0) {
        $ContentResponse.Add(
            'message',
            'Welcome to the Icinga for Windows API checker. To execute checks, please use the command parameter. For providing arguments, you will have to submit a post with JSON encoded arguments. Example: /v1/checker?command=Invoke-IcingaCheckCPU'
        );
    }

    # Send the response to the client
    Send-IcingaTCPClientMessage -Message (
        New-IcingaTCPClientRESTMessage `
            -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.Ok) `
            -ContentBody $ContentResponse
    ) -Stream $Connection.Stream;
}
