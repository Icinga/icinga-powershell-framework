function Exit-IcingaExecutePlugin()
{
    param (
        [string]$Command = ''
    );

    # We need to fix the argument encoding hell
    [hashtable]$ConvertedArgs      = ConvertTo-IcingaPowerShellArguments -Arguments $args;
    [string]$JEAProfile            = Get-IcingaJEAContext;
    [bool]$CheckByIcingaForWindows = $FALSE;
    [bool]$CheckByJEAShell         = $FALSE;

    if ($args -Contains '-IcingaForWindowsRemoteExecution') {
        $CheckByIcingaForWindows = $TRUE;
    }
    if ($args -Contains '-IcingaForWindowsJEARemoteExecution') {
        $CheckByJEAShell = $TRUE;
    }

    # We use the plugin check_by_icingaforwindows.ps1 to execute
    # checks from a Linux/Windows remote source
    if ($CheckByIcingaForWindows) {
        # First try to queue the check over the REST-Api
        $CheckResult = Invoke-IcingaInternalServiceCall -Command $Command -Arguments $ConvertedArgs -NoExit;

        if ($null -ne $CheckResult) {
            # Seems we got a result
            Write-IcingaConsolePlain -Message $CheckResult;

            # Do not close the session, we need to read the ExitCode from Get-IcingaInternalPluginExitCode
            # The plugin itself will terminate the session
            return;
        }

        # We couldn't use our Rest-Api and Api-Checks feature, then lets execute the plugin locally
        # Set daemon true, because this will change internal handling for errors and plugin output
        $Global:Icinga.Protected.RunAsDaemon = $TRUE;

        try {
            # Execute our plugin
            (& $Command @ConvertedArgs) | Out-Null;
        } catch {
            # Handle errors within our plugins
            # If anything goes wrong handle the error very detailed

            $Global:Icinga.Protected.RunAsDaemon = $FALSE;
            Write-IcingaExecutePluginException -Command $Command -ErrorObject $_ -Arguments $ConvertedArgs;
            $ConvertedArgs.Clear();

            # Do not close the session, we need to read the ExitCode from Get-IcingaInternalPluginExitCode
            # The plugin itself will terminate the session
            return;
        }

        # Disable it again - we need to write data to our shell now. Not very intuitive, but it is the easiest
        # solution to do it this way
        $Global:Icinga.Protected.RunAsDaemon = $FALSE;

        # Now print the result to shell
        Write-IcingaPluginResult -PluginOutput (Get-IcingaInternalPluginOutput) -PluginPerfData (Get-IcingaCheckSchedulerPerfData);

        # Do not close the session, we need to read the ExitCode from Get-IcingaInternalPluginExitCode
        # The plugin itself will terminate the session
        return;
    }

    # Regardless of JEA enabled or disabled, forward all checks to the internal API
    # and check if we get a result from there
    Invoke-IcingaInternalServiceCall -Command $Command -Arguments $ConvertedArgs;

    try {
        # If the plugin is not installed, throw a good exception
        Exit-IcingaPluginNotInstalled -Command $Command;

        # In case we have JEA enabled on our system, this shell currently open most likely has no
        # JEA configuration installed. This is because a JEA shell will not return an exit code and
        # Icinga relies on that. Therefor we will try to open a new PowerShell with the JEA configuration
        # assigned for Icinga for Windows, execute the plugins there and return the result
        if ([string]::IsNullOrEmpty($JEAProfile) -eq $FALSE) {
            $ErrorHandler = ''
            $JEARun = (
                & powershell.exe -ConfigurationName $JEAProfile -NoLogo -NoProfile -Command {
                    # Load Icinga for Windows
                    Use-Icinga;

                    # Enable our JEA context
                    $Global:Icinga.Protected.JEAContext = $TRUE;

                    # Parse the arguments our previous shell received
                    $Command   = $args[0];
                    $Arguments = $args[1];
                    $Output    = '';

                    try {
                        # Try executing our checks, store the exit code and plugin output
                        $ExitCode = (& $Command @Arguments);
                        $Output   = (Get-IcingaInternalPluginOutput);
                        $ExitCode = (Get-IcingaInternalPluginExitCode);
                    } catch {
                        # If we failed for some reason, print a detailed error and use exit code 3 to mark the check as unkown
                        $Output   = [string]::Format('[UNKNOWN] Icinga Exception: Error while executing plugin in JEA context{0}{0}{1}', (New-IcingaNewLine), $_.Exception.Message);
                        $ExitCode = 3;
                    }

                    # Return the result to our main PowerShell
                    return @{
                        'Output'   = $Output;
                        'PerfData' = (Get-IcingaCheckSchedulerPerfData)
                        'ExitCode' = $ExitCode;
                    }
                } -args $Command, $ConvertedArgs
            ) 2>$ErrorHandler;

            # If we have an exit code larger or equal 0, the execution inside the JEA shell was successfully and we can share the result
            # In case we had an error inside the JEA shell, it will returned here as well
            if ($LASTEXITCODE -ge 0) {
                Write-IcingaPluginResult -PluginOutput $JEARun.Output -PluginPerfData $JEARun.PerfData;
                exit $JEARun.ExitCode;
            } else {
                # If for some reason the PowerShell could not be started within JEA context, we can throw an exception with exit code 3
                # to mark the check as unknown including our error message
                Write-IcingaConsolePlain '[UNKNOWN] Icinga Exception: Unable to start the PowerShell.exe with the provided JEA profile "{0}" for CheckCommand: {1}' -Objects $JEAProfile, $Command;
                exit 3;
            }
        } else {
            # If we simply run the check without JEA context or from remote, we can just execute the plugin and
            # exit with the exit code received from the result
            exit (& $Command @ConvertedArgs);
        }
    } catch {
        # If anything goes wrong handle the error
        Write-IcingaExecutePluginException -Command $Command -ErrorObject $_ -Arguments $ConvertedArgs;
        $ConvertedArgs.Clear();

        exit 3;
    }
}
