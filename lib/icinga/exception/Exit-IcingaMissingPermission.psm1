Import-IcingaLib icinga\enums;
Import-IcingaLib icinga\exception;

function Exit-IcingaMissingPermission()
{
    param(
        [string]$InputString,
        [string]$StringPattern,
        [string]$CustomMessage,
        [string]$ExeptionType
    );

    if ($null -eq $InputString -Or [string]::IsNullOrEmpty($InputString)) {
        return;
    }

    if (-Not $InputString.Contains($StringPattern)) {
        return;
    }

    $OutputMessage = '{0}: Icinga Permission Error was thrown: {3}{1}{1}{2}';
    if ([string]::IsNullOrEmpty($CustomMessage) -eq $TRUE) {
        $OutputMessage = '{0}: Icinga Permission Error was thrown {1}{1}{2}{3}';
    }

    $OutputMessage = [string]::Format(
        $OutputMessage,
        $IcingaEnums.IcingaExitCodeText.($IcingaEnums.IcingaExitCode.Unknown),
        "`r`n",
        $ExeptionType,
        $CustomMessage
    );

    Write-Host $OutputMessage;
    exit $IcingaEnums.IcingaExitCode.Unknown;
}
