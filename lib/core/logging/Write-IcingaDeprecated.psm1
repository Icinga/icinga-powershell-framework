function Write-IcingaDeprecated()
{
    param (
        [string]$Function,
        [string]$Argument
    );

    if ([string]::IsNullOrEmpty($Function)) {
        return;
    }

    $Message = 'The called function or method "{0}" is deprecated. Please update your component or contact the developer to update the component accordingly.';

    if ([string]::IsNullOrEmpty($Argument) -eq $FALSE) {
        $Message = 'The function or method "{0}" is called with deprecated argument "{1}". Please update your component or contact the developer to update the component accordingly.';
    }

    Write-IcingaConsoleOutput `
        -Message $Message `
        -Objects $Function, $Argument `
        -ForeColor 'Cyan' `
        -Severity 'Deprecated';

    Write-IcingaEventMessage -EventId 1001 -Namespace 'Framework' -Objects `
        ([string]::Format('Command or Method: {0}', $Function)),
        ([string]::Format('Argument: {0}', $Argument)),
        (Get-PSCallStack);
}
