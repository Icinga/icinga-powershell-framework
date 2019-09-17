function Exit-IcingaThrowException()
{
    param(
        [string]$InputString,
        [string]$StringPattern,
        [string]$CustomMessage,
        [string]$ExceptionThrown,
        [ValidateSet('Permission','Input','Unhandled')]
        [string]$ExceptionType    = 'Unhandled',
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
        'Unhandled' {
            $ExceptionTypeString = 'Unhandled';
        };
    }

    [string]$ExceptionName = '';

    if ($null -ne $ExceptionMessageLib) {
        foreach ($definedError in $ExceptionMessageLib.Keys) {
            if ($ExceptionMessageLib.$definedError -eq $ExceptionThrown) {
                $ExceptionName = $definedError;
                break;
            }
        }
    } else {
        $ExceptionName   = 'Unhandled Exception';
        $ExceptionThrown = [string]::Format(
            'Unhandled exception occured:{0}{1}',
            "`r`n",
            $InputString
        );
    }

    $OutputMessage = '{0}: Icinga {5} Error was thrown: {3}: {4}{1}{1}{2}';
    if ([string]::IsNullOrEmpty($CustomMessage) -eq $TRUE) {
        $OutputMessage = '{0}: Icinga {5} Error was thrown: {3}{1}{1}{2}{4}';
    }

    $OutputMessage = [string]::Format(
        $OutputMessage,
        $IcingaEnums.IcingaExitCodeText.($IcingaEnums.IcingaExitCode.Unknown),
        "`r`n",
        $ExceptionThrown,
        $ExceptionName,
        $CustomMessage,
        $ExceptionTypeString
    );

    Write-Host $OutputMessage;
    exit $IcingaEnums.IcingaExitCode.Unknown;
}
