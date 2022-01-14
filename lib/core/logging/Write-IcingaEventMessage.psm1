function Write-IcingaEventMessage()
{
    param (
        [int]$EventId      = 0,
        [string]$Namespace = $null,
        [array]$Objects    = @(),
        $ExceptionObject   = $null
    );

    if ($EventId -eq 0 -Or [string]::IsNullOrEmpty($Namespace)) {
        return;
    }

    [string]$EntryType = $IcingaEventLogEnums[$Namespace][$EventId].EntryType;
    [string]$Message   = $IcingaEventLogEnums[$Namespace][$EventId].Message;
    [string]$Details   = $IcingaEventLogEnums[$Namespace][$EventId].Details;

    if ([string]::IsNullOrEmpty($Details)) {
        $Details = '';
    }
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = '';
    }

    [string]$ObjectDump = '';

    if ($Objects.Count -eq 0) {
        $ObjectDump = [string]::Format(
            '{0}No additional object details provided.',
            (New-IcingaNewLine)
        );
    }

    foreach ($entry in $Objects) {
        $ObjectDump = [string]::Format(
            '{0}{1}',
            $ObjectDump,
            ($entry | Out-String)
        );
    }

    [string]$EventLogMessage = [string]::Format(
        '{0}{1}{1}{2}{3}{1}{1}Object details:{1}{4}',
        $Message,
        (New-IcingaNewLine),
        $Details,
        (Get-IcingaExceptionString -ExceptionObject $ExceptionObject),
        $ObjectDump
    );

    if ($null -eq $EntryType -Or $null -eq $Message) {
        return;
    }

    [int]$MaxEventLogMessageSize = 30000;

    if ($EventLogMessage.Length -ge $MaxEventLogMessageSize) {
        while ($EventLogMessage.Length -ge $MaxEventLogMessageSize) {
            $CutMessage = $EventLogMessage.Substring(0, $MaxEventLogMessageSize);
            Write-EventLog `
                -LogName 'Icinga for Windows' `
                -Source ([string]::Format('IfW::{0}', $Namespace)) `
                -EntryType $EntryType `
                -EventId $EventId `
                -Message $CutMessage;

            $EventLogMessage = $EventLogMessage.Substring($MaxEventLogMessageSize, $EventLogMessage.Length - $MaxEventLogMessageSize);
        }
    }

    if ([string]::IsNullOrEmpty($EventLogMessage)) {
        return;
    }

    Write-EventLog `
        -LogName 'Icinga for Windows' `
        -Source ([string]::Format('IfW::{0}', $Namespace)) `
        -EntryType $EntryType `
        -EventId $EventId `
        -Message $EventLogMessage;
}
