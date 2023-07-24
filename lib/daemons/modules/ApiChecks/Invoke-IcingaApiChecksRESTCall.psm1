function Invoke-IcingaApiChecksRESTCall()
{
    param (
        [Hashtable]$Request    = @{ },
        [Hashtable]$Connection = @{ },
        [string]$ApiVersion    = $null
    );

    [Hashtable]$ContentResponse = @{ };

    # Short our call
    $CheckerAliases        = $Global:Icinga.Public.Daemons.RESTApi.CommandAliases.checker;
    $CheckConfig           = $Request.Body;
    [int]$ExitCode         = 3; #Unknown
    [string]$CheckResult   = '';
    [string]$InternalError = '';

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

        if ((Test-IcingaFunction -Name $ExecuteCommand) -eq $FALSE) {

            Add-IcingaHashtableItem `
                -Hashtable $ContentResponse `
                -Key $ExecuteCommand `
                -Value @{
                    'exitcode'    = 3;
                    'checkresult' = [string]::Format('[UNKNOWN] Icinga plugin not found exception: Command "{0}" is not present on the system{1}{1}The command "{0}" you are trying to execute over the REST-Api endpoint "apichecks" is not available on the system.', $ExecuteCommand, (New-IcingaNewLine));
                    'perfdata'    = @();
                } | Out-Null;

            Send-IcingaTCPClientMessage -Message (
                New-IcingaTCPClientRESTMessage `
                    -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Not Found') `
                    -ContentBody $ContentResponse
            ) -Stream $Connection.Stream;

            return;
        }

        if ((Test-IcingaRESTApiCommand -Command $ExecuteCommand -Endpoint 'apichecks') -eq $FALSE) {

            Add-IcingaHashtableItem `
                -Hashtable $ContentResponse `
                -Key $ExecuteCommand `
                -Value @{
                    'exitcode'    = 3;
                    'checkresult' = [string]::Format('[UNKNOWN] Icinga Permission error was thrown: Permission denied for command "{0}"{1}{1}The command "{0}" you are trying to execute over the REST-Api endpoint "apichecks" is not whitelisted for remote execution.', $ExecuteCommand, (New-IcingaNewLine));
                    'perfdata'    = @();
                } | Out-Null;

            Send-IcingaTCPClientMessage -Message (
                New-IcingaTCPClientRESTMessage `
                    -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.'Forbidden') `
                    -ContentBody $ContentResponse
            ) -Stream $Connection.Stream;

            return;
        }

        Write-IcingaDebugMessage -Message ('Executing API check for command: ' + $ExecuteCommand);

        if ([string]::IsNullOrEmpty($CheckConfig) -eq $FALSE -And $Request.Method -eq 'POST') {
            # Convert our JSON config for checks to a PSCustomObject
            $PSArguments = ConvertFrom-Json -InputObject $CheckConfig;

            # Read the command definition and arguments type, to ensure we properly handle SecureStrings
            $CommandHelp    = Get-Help -Name $ExecuteCommand -Full;
            $CommandDetails = @{ };

            foreach ($parameter in $CommandHelp.parameters.parameter) {
                $CommandDetails.Add($parameter.Name, $parameter.Type.Name);
            }

            # For executing the checks, we will require the data as
            # hashtable, so declare it here
            [hashtable]$Arguments = @{ };

            # Now convert our custom object by Key<->Value to
            # a valid hashtable, allowing us to parse arguments
            # to our check command
            $PSArguments.PSObject.Properties | ForEach-Object {
                $CmdArgValue        = $_.Value;
                [string]$CmdArgName = $_.Name;

                # Ensure we can use both, `-MyArgument` and `MyArgument` as valid input
                if ($CmdArgName[0] -eq '-') {
                    $CmdArgName = $CmdArgName.Substring(1, $CmdArgName.Length - 1);
                }

                # Ensure we convert strings to SecureString, in case the plugin argument requires it
                if ($CommandDetails.ContainsKey($CmdArgName) -And $CommandDetails[$CmdArgName] -Like 'SecureString') {
                    $CmdArgValue = ConvertTo-IcingaSecureString -String $_.Value;
                }

                Add-IcingaHashtableItem `
                    -Hashtable $Arguments `
                    -Key $CmdArgName `
                    -Value $CmdArgValue | Out-Null;
            };

            try {
                [int]$ExitCode = & $ExecuteCommand @Arguments;
            } catch {
                [int]$ExitCode = 3;
                $InternalError = $_.Exception.Message;
            }
        } elseif ($Request.Method -eq 'GET') {
            try {
                [int]$ExitCode = & $ExecuteCommand;
            } catch {
                [int]$ExitCode = 3;
                $InternalError = $_.Exception.Message;
            }
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
        if ([string]::IsNullOrEmpty($InternalError)) {
            $CheckResult = Get-IcingaCheckSchedulerPluginOutput;
        } else {
            if ($InternalError.Contains('[UNKNOWN]') -eq $FALSE) {
                # Ensure we format the error message more user friendly
                $CheckResult = [string]::Format('[UNKNOWN] Icinga Plugin execution error was thrown during API request:{0}{0}{1}', (New-IcingaNewLine), $InternalError);
            } else {
                $CheckResult = $InternalError;
            }
        }
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
