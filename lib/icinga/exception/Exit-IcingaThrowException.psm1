function Exit-IcingaThrowException()
{
    param(
        [string]$InputString,
        [string]$StringPattern,
        [string]$CustomMessage,
        $ExceptionThrown,
        [ValidateSet('Permission', 'Input', 'Configuration', 'Connection', 'Unhandled', 'Custom')]
        [string]$ExceptionType    = 'Unhandled',
        [string]$KnowledgeBaseId,
        [switch]$Force
    );

    if ($Force -eq $FALSE) {
        if ($null -eq $InputString -Or [string]::IsNullOrEmpty($InputString)) {
            return;
        }

        if (-Not $InputString.Contains($StringPattern)) {
            return;
        }
    }

    $ExceptionMessageLib = $null;
    $ExceptionTypeString = '';

    switch ($ExceptionType) {
        'Permission' {
            $ExceptionTypeString = 'Permission';
            $ExceptionMessageLib = $IcingaExceptions.Permission;
        };
        'Input' {
            $ExceptionTypeString = 'Invalid Input';
            $ExceptionMessageLib = $IcingaExceptions.Inputs;
        };
        'Configuration' {
            $ExceptionTypeString = 'Invalid Configuration';
            $ExceptionMessageLib = $IcingaExceptions.Configuration;
        };
        'Connection' {
            $ExceptionTypeString = 'Connection error';
            $ExceptionMessageLib = $IcingaExceptions.Connection;
        };
        'Unhandled' {
            $ExceptionTypeString = 'Unhandled';
        };
        'Custom' {
            $ExceptionTypeString = 'Custom';
        };
    }

    [string]$ExceptionName = '';
    [string]$ExceptionIWKB = $KnowledgeBaseId;

    if ($ExceptionThrown -is [hashtable]) {
        $ExceptionIWKB   = $ExceptionThrown.IWKB;
        $ExceptionThrown = $ExceptionThrown.Message;
    }

    if ($null -ne $ExceptionMessageLib) {
        foreach ($definedError in $ExceptionMessageLib.Keys) {
            if ($ExceptionMessageLib.$definedError -eq $ExceptionThrown) {
                $ExceptionName = $definedError;
                break;
            }
        }
    } else {
        $ExceptionName   = [string]::Format('{0} Exception', $ExceptionTypeString);
        $ExceptionThrown = [string]::Format(
            '{0} exception occured:{1}{2}',
            $ExceptionTypeString,
            "`r`n",
            $InputString
        );
    }

    if ([string]::IsNullOrEmpty($ExceptionIWKB) -eq $FALSE) {
        $ExceptionIWKB = [string]::Format(
            '{0}{0}Further details can be found on the Icinga for Windows Knowledge base: https://icinga.com/docs/windows/latest/doc/knowledgebase/{1}',
            (New-IcingaNewLine), 
            $ExceptionIWKB
        );
    }

    $OutputMessage = '{0}: Icinga {6} Error was thrown: {4}: {5}{2}{2}{3}{1}';
    if ([string]::IsNullOrEmpty($CustomMessage) -eq $TRUE) {
        $OutputMessage = '{0}: Icinga {6} Error was thrown: {4}{2}{2}{3}{5}{1}';
    }

    $OutputMessage = [string]::Format(
        $OutputMessage,
        $IcingaEnums.IcingaExitCodeText.($IcingaEnums.IcingaExitCode.Unknown),
        $ExceptionIWKB,
        (New-IcingaNewLine),
        $ExceptionThrown,
        $ExceptionName,
        $CustomMessage,
        $ExceptionTypeString
    );

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        Write-IcingaConsolePlain $OutputMessage;
        exit $IcingaEnums.IcingaExitCode.Unknown;
    }
}
