function Exit-IcingaThrowCritical()
{
    param (
        [string]$Message      = '',
        [string]$FilterString = $null,
        [string]$SearchString = $null,
        [switch]$Force        = $FALSE
    );

    if ($Force -eq $FALSE) {
        if ([string]::IsNullOrEmpty($FilterString) -Or [string]::IsNullOrEmpty($SearchString)) {
            return;
        }

        if ($FilterString -NotLike "*$SearchString*") {
            return;
        }
    }

    [string]$OutputMessage = [string]::Format(
        '[CRITICAL] {0}',
        $Message
    );

    Set-IcingaInternalPluginExitCode -ExitCode $IcingaEnums.IcingaExitCode.Critical;
    Set-IcingaInternalPluginException -PluginException $OutputMessage;

    if ($Global:Icinga.Protected.RunAsDaemon -eq $TRUE -Or $Global:Icinga.Protected.JEAContext -eq $TRUE) {
        throw $OutputMessage;

        # Just in case we don't end - shouldn't happen anyway
        return;
    }

    Write-IcingaConsolePlain $OutputMessage;
    exit $IcingaEnums.IcingaExitCode.Critical;
}
