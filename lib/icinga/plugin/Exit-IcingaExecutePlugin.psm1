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

        Write-IcingaConsolePlain '[UNKNOWN] Icinga Exception: {0}{1}{1}CheckCommand: {2}{1}Arguments: {3}{1}{1}StackTrace:{1}{4}' -Objects $ExMsg, (New-IcingaNewLine), $Command, $args, $StackTrace;
        exit 3;
    }
}
