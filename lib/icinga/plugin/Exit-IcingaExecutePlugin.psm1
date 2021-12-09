function Exit-IcingaExecutePlugin()
{
    param (
        [string]$Command = ''
    );

    $JEAProfile = Get-IcingaJEAContext;

    Invoke-IcingaInternalServiceCall -Command $Command -Arguments $args;

    try {
        Exit-IcingaPluginNotInstalled -Command $Command;

        if ([string]::IsNullOrEmpty($JEAProfile) -eq $FALSE) {
            $ErrorHandler = ''
            $JEARun = (
                & powershell.exe -ConfigurationName $JEAProfile -NoLogo -NoProfile -Command {
                    Use-Icinga;

                    $Global:Icinga.Protected.JEAContext = $TRUE;

                    $Command   = $args[0];
                    $Arguments = $args[1];
                    $Output    = '';

                    try {
                        $ExitCode = (& $Command @Arguments);
                        $Output   = (Get-IcingaInternalPluginOutput);
                        $ExitCode = (Get-IcingaInternalPluginExitCode);
                    } catch {
                        $Output   = [string]::Format('[UNKNOWN] Icinga Exception: Error while executing plugin in JEA context{0}{0}{1}', (New-IcingaNewLine), $_.Exception.Message);
                        $ExitCode = 3;
                    }

                    return @{
                        'Output'   = $Output;
                        'PerfData' = (Get-IcingaCheckSchedulerPerfData)
                        'ExitCode' = $ExitCode;
                    }
                } -args $Command, $args
            ) 2>$ErrorHandler;

            if ($LASTEXITCODE -ge 0) {
                Write-IcingaPluginResult -PluginOutput $JEARun.Output -PluginPerfData $JEARun.PerfData;
                exit $JEARun.ExitCode;
            } else {
                Write-IcingaConsolePlain '[UNKNOWN] Icinga Exception: Unable to start the PowerShell.exe with the provided JEA profile "{0}" for CheckCommand: {1}' -Objects $JEAProfile, $Command;
                exit 3;
            }
        } else {
            exit (& $Command @args);
        }
    } catch {
        $ExMsg      = $_.Exception.Message;
        $StackTrace = $_.ScriptStackTrace;
        $ExErrorId  = $_.FullyQualifiedErrorId;
        $ArgName    = $_.Exception.ParameterName;
        $ListArgs   = $args;

        if ($ExErrorId -Like "*ParameterArgumentTransformationError*" -And $ExMsg.Contains('System.Security.SecureString')) {
            $ExMsg = [string]::Format(
                'Cannot bind parameter {0}. Cannot convert the provided value for argument "{0}" of type "System.String" to type "System.Security.SecureString".',
                $ArgName
            );

            $args.Clear();
            $ListArgs = 'Hidden for security reasons';
        }

        Write-IcingaConsolePlain '[UNKNOWN] Icinga Exception: {0}{1}{1}CheckCommand: {2}{1}Arguments: {3}{1}{1}StackTrace:{1}{4}' -Objects $ExMsg, (New-IcingaNewLine), $Command, $ListArgs, $StackTrace;
        exit 3;
    }
}
