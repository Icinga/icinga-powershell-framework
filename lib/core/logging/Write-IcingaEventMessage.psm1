function Write-IcingaEventMessage()
{
    param (
        [int]$EventId      = 0,
        [string]$Namespace = $null,
        [array]$Objects    = @()
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
            '{0}{0}No additional object details provided.',
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
        '{0}{1}{1}{2}{1}{1}Object dumps if available:{1}{3}',
        $Message,
        (New-IcingaNewLine),
        $Details,
        $ObjectDump

    );

    if ($null -eq $EntryType -Or $null -eq $Message) {
        return;
    }

    Write-EventLog -LogName Application `
        -Source 'Icinga for Windows' `
        -EntryType $EntryType `
        -EventId $EventId `
        -Message $EventLogMessage;
}
