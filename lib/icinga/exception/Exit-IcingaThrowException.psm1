function Exit-IcingaThrowException()
{
    param(
        [string]$InputString,
        [string]$StringPattern,
        [string]$CustomMessage,
        $ExceptionThrown,
        [ValidateSet('Permission', 'Input', 'Configuration', 'Connection', 'Unhandled', 'Custom')]
        [string]$ExceptionType    = 'Unhandled',
        [hashtable]$ExceptionList = @{ },
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

    if ($null -eq $ExceptionList -Or $ExceptionList.Count -eq 0) {
        $ExceptionList = $IcingaExceptions;
    }

    $ExceptionMessageLib = $null;
    $ExceptionTypeString = '';

    switch ($ExceptionType) {
        'Permission' {
            $ExceptionTypeString = 'Permission';
            $ExceptionMessageLib = $ExceptionList.Permission;
        };
        'Input' {
            $ExceptionTypeString = 'Invalid Input';
            $ExceptionMessageLib = $ExceptionList.Inputs;
        };
        'Configuration' {
            $ExceptionTypeString = 'Invalid Configuration';
            $ExceptionMessageLib = $ExceptionList.Configuration;
        };
        'Connection' {
            $ExceptionTypeString = 'Connection error';
            $ExceptionMessageLib = $ExceptionList.Connection;
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

    if ($null -ne $ExceptionMessageLib) {
        foreach ($definedError in $ExceptionMessageLib.Keys) {
            if ($ExceptionMessageLib.$definedError -eq $ExceptionThrown) {
                $ExceptionName = $definedError;
                break;
            }
        }
    }
    if ($null -eq $ExceptionMessageLib -Or [string]::IsNullOrEmpty($ExceptionName)) {
        $ExceptionName   = [string]::Format('{0} Exception', $ExceptionTypeString);
        if ([string]::IsNullOrEmpty($InputString)) {
            $InputString = $ExceptionThrown;
        }
        $ExceptionThrown = [string]::Format(
            '{0} exception occured:{1}{2}',
            $ExceptionTypeString,
            "`r`n",
            $InputString
        );
    }

    if ($ExceptionThrown -is [hashtable]) {
        $ExceptionIWKB   = $ExceptionThrown.IWKB;
        $ExceptionThrown = $ExceptionThrown.Message;
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

    if ($null -eq $global:IcingaDaemonData -Or $global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        Write-IcingaConsolePlain $OutputMessage;
        exit $IcingaEnums.IcingaExitCode.Unknown;
    }
}
