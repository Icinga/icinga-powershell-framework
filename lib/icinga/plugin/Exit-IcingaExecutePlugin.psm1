function Exit-IcingaExecutePlugin()
{
    param (
        [string]$Command = ''
    );

    Invoke-IcingaInternalServiceCall -Command $Command -Arguments $args;

    try {
        # Load the entire framework now, as we require to execute plugins locally
        if ($null -eq $global:IcingaDaemonData) {
            Use-Icinga;
        }

        Exit-IcingaPluginNotInstalled -Command $Command;

        exit (& $Command @args);
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
