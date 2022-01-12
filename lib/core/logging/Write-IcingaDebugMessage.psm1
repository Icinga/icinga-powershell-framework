function Write-IcingaDebugMessage()
{
    param (
        [string]$Message,
        [array]$Objects  = @(),
        $ExceptionObject = $null
    );

    if ([string]::IsNullOrEmpty($Message)) {
        return;
    }

    if ($null -eq $global:IcingaDaemonData -Or $global:IcingaDaemonData.DebugMode -eq $FALSE) {
        return;
    }

    [array]$DebugContent = @($Message);
    $DebugContent += $Objects;

    Write-IcingaEventMessage -EventId 1000 -Namespace 'Framework' -ExceptionObject $ExceptionObject -Objects $DebugContent;
}
