function Exit-IcingaExecutePlugin()
{
    param (
        [string]$Command = ''
    );

    Exit-IcingaPluginNotInstalled -Command $Command;

    Invoke-IcingaInternalServiceCall -Command $Command -Arguments $args;

    try {
        # Load the entire framework now, as we require to execute plugins locally
        if ($null -eq $global:IcingaDaemonData) {
            Use-Icinga;
        }

        exit (& $Command @args);
    } catch {
        $ExMsg = $_.Exception.Message;
        Write-IcingaConsolePlain '[UNKNOWN]: {0}{1}{1}CheckCommand: {2}{1}Arguments: {3}' -Objects $ExMsg, (New-IcingaNewLine), $Command, $args;
        exit 3;
    }
}
