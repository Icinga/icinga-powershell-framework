function Write-IcingaExecutePluginException()
{
    param (
        $Command     = '',
        $ErrorObject = $null,
        $Arguments   = @()
    );

    if ($null -eq $ErrorObject) {
        return;
    }

    $ExMsg      = $ErrorObject.Exception.Message;
    $StackTrace = $ErrorObject.ScriptStackTrace;
    $ExErrorId  = $ErrorObject.FullyQualifiedErrorId;
    $ArgName    = $ErrorObject.Exception.ParameterName;
    $ListArgs   = @();

    foreach ($entry in $Arguments) {
        if ($entry -eq '-IcingaForWindowsRemoteExecution' -Or $entry -eq '-IcingaForWindowsJEARemoteExecution') {
            continue;
        }
        $ListArgs += $entry;
    }

    if ($ExErrorId -Like "*ParameterArgumentTransformationError*" -And $ExMsg.Contains('System.Security.SecureString')) {
        $ExMsg = [string]::Format(
            'Cannot bind parameter {0}. Cannot convert the provided value for argument "{0}" of type "System.String" to type "System.Security.SecureString".',
            $ArgName
        );

        $Arguments.Clear();
        $ListArgs = 'Hidden for security reasons';
    }

    Write-IcingaConsolePlain '[UNKNOWN] Icinga Exception: {0}{1}{1}CheckCommand: {2}{1}Arguments: {3}{1}{1}StackTrace:{1}{4}' -Objects $ExMsg, (New-IcingaNewLine), $Command, $ListArgs, $StackTrace;
    $Global:Icinga.Private.Scheduler.ExitCode = 3;
}
